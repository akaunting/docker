## Setup behavior
Running each deployment on different nodes can cause performance issues, best to pin akaunting, mariadb and redis to the same node. Get the database and redis running first.

In the akaunting.yaml, set to install mode in both the akaunting and akaunting-worker containers:

```yaml
- name: APP_INSTALLED
  value: "false"
- name: AKAUNTING_SETUP
  value: "true"
```

The setup can take a while, so watch the logs until it completes. This should take you to the the language and database forms. These should be filled with whatever you put in the yaml. At this point scale the deployment to 0 and edit the yaml...

```yaml
- name: APP_INSTALLED
  value: "true"
- name: AKAUNTING_SETUP
  value: "false"
```

3. apply the manifest again with and scale back up to 1.

After the app comes back up, you should land on the login screen. After logging in, Akaunting will prompt for the API key, remaining business details such as currency and address information.

## TRAEFIK
If you get problems with the container creating HTTP links when HTTPS are needed... this should fix it...

`sudo vim /var/lib/rancher/k3s/server/manifests/traefik-config.yaml`

```yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: traefik
  namespace: kube-system
spec:
  valuesContent: |-
    ports:
      web:
        forwardedHeaders:
          insecure: true
      websecure:
        forwardedHeaders:
          insecure: true
```
It's best to do this before running the yamls.

## License

This project is released under the GPLv3 license. See [LICENSE.txt](LICENSE.txt).
