# DNS + TLS setup (DuckDNS + cert-manager)

## Architecture choice: same-origin

One DuckDNS subdomain (e.g. `phoenix-mariam.duckdns.org`) serves both the
frontend and the API behind a single Ingress: `/` → frontend, `/api` →
backend. One hostname means one TLS cert, and no CORS configuration at
all, since the browser only ever talks to one origin. This sidesteps the
exact class of `baseURL`/CORS bug you ran into earlier when deploying
this same app to a single EC2 box.

## 1. Register a DuckDNS subdomain
1. Go to https://www.duckdns.org and sign in (GitHub/Google/etc).
2. Under "add domain," create a subdomain, e.g. `phoenix-mariam`
   → this gives you `phoenix-mariam.duckdns.org`.
3. Set the IP field to your **control plane's public IP**
   (any of your 3 node public IPs actually works — k3s's built-in
   ServiceLB binds LoadBalancer-type services like Traefik to every
   node — but the control plane IP is the simplest to remember).
4. Propagation is near-instant. Confirm with:
   ```bash
   nslookup phoenix-mariam.duckdns.org
   ```
   It should resolve to the IP you set.

DigitalOcean droplet IPs are static (they don't change unless you
destroy/recreate the droplet), so a one-time DNS entry is fine for this
project — you don't need DuckDNS's dynamic-IP updater script.

## 2. Install cert-manager
```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```
(If a specific version is required for your course, add `--version vX.Y.Z`
— check https://cert-manager.io for the current stable release.)

Verify it's running:
```bash
kubectl get pods -n cert-manager
```
You should see `cert-manager`, `cert-manager-cainjector`, and
`cert-manager-webhook` all `Running`.

## 3. Apply the ClusterIssuers
`clusterissuer.yaml` in this folder defines two issuers: staging and
production. **Test with staging first** — Let's Encrypt's production
rate limits are easy to hit while you're still debugging Ingress config,
and staging certs work identically for testing purposes (browsers just
flag them as untrusted, which is expected and fine).

Before applying, replace `YOUR_EMAIL@example.com` in both issuers with
your real email (Let's Encrypt uses it for expiry notices only).

```bash
kubectl apply -f manifests/platform/clusterissuer.yaml
kubectl get clusterissuer
```
Both should show `READY: True`.

## 4. metrics-server
k3s bundles metrics-server by default — you likely don't need to install
anything. Confirm it's there:
```bash
kubectl get deployment -n kube-system metrics-server
kubectl top nodes
```
If `kubectl top nodes` returns data, you're set for the HPA work later.

## Next step
Once staging issues a cert successfully against your Ingress (built in
the next phase), switch the Ingress's `cert-manager.io/cluster-issuer`
annotation from `letsencrypt-staging` to `letsencrypt-prod` for the real,
trusted certificate.
