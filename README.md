# Helm (Kubernetes) plugin for drone.io

[![Build Status](https://drone.sohohousedigital.com/api/badges/ipedrazas/drone-helm/status.svg)](https://drone.sohohousedigital.com/ipedrazas/drone-helm)

This plugin allows to deploy a [Helm](https://github.com/kubernetes/helm) chart into a [Kubernetes](https://github.com/kubernetes/kubernetes) cluster.

For example, this configuration will deploy my-app using a chart located in the repo called `my-chart`

```YAML
pipeline:
  helm_deploy:
  image: quay.io/ipedrazas/drone-helm
  skip_tls_verify: true
  chart: ./charts/my-chart
  release: ${DRONE_BRANCH}
  values: secret.password=${SECRET_PASSWORD},image.tag=${DRONE_BRANCH}-${DRONE_COMMIT_SHA:0:7}
  prefix: STAGING
  debug: true
  when:
    branch: [master]
```

There are two secrets you have to create (Note that if you specify the prefix, your secrets have to be created using that prefix):

```Bash
drone secret add --image=quay.io/ipedrazas/drone-helm \
  your-user/your-repo STAGING_API_SERVER https://mykubernetesapiserver

drone secret add --image=quay.io/ipedrazas/drone-helm \
  your-user/your-repo STAGING_KUBERNETES_TOKEN eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJrdWJ...

drone secret add --image=quay.io/ipedrazas/drone-helm \
  your-user/your-repo STAGING_SECRET_PASSWORD Sup3rS3cr3t
```

`Prefix` helps you to use the same block in different environments:
```YAML
pipeline:
  helm_deploy_staging:
  image: quay.io/ipedrazas/drone-helm
  skip_tls_verify: true
  chart: ./charts/my-chart
  release: ${DRONE_BRANCH}
  values: secret.password=${SECRET_PASSWORD},image.tag=${DRONE_BRANCH}-${DRONE_COMMIT_SHA:0:7}
  prefix: STAGING
  debug: true
  when:
    branch:
      exclude: [ master ]

pipeline_production:
  helm_deploy:
  image: quay.io/ipedrazas/drone-helm
  skip_tls_verify: true
  chart: ./charts/my-chart
  release: ${DRONE_BRANCH}
  values: secret.password=${SECRET_PASSWORD},image.tag=${DRONE_BRANCH}-${DRONE_COMMIT_SHA:0:7}
  prefix: PROD
  debug: true
  when:
    branch: [master]
```

This last block defines how the plugin will deploy


To test the plugin, you can run `minikube` and just run the docker image as follows:
```Bash
docker run --rm \
  -e PLUGIN_API_SERVER=https://192.168.64.5:8443 \
  -e PLUGIN_TOKEN="" \
  -e PLUGIN_NAMESPACE=default \
  -e PLUGIN_SKIP_TLS_VERIFY=true \
  -e PLUGIN_RELEASE=my-release \
  -e PLUGIMN_CHART=stable/redis \
  -e PLUGIN_VALUES="tag=TAG,api=API" \
  -e PLUGIN_DEBUG=true \
  -e PLUGIN_DRY_RUN=true \
  -e DRONE_BUILD_EVENT=push \
  quay.io/ipedrazas/drone-helm
```

This plugin installs [Tiller](https://github.com/kubernetes/helm/blob/master/docs/architecture.md) in the cluster, if you want to specify the namespace where `tiller` ins installed, use the `tiller_ns` attribute.

The following example will install `tiller` in the `operations` namespace:
```YAML
pipeline_production:
  helm_deploy:
  image: quay.io/ipedrazas/drone-helm
  skip_tls_verify: true
  chart: ./charts/my-chart
  release: ${DRONE_BRANCH}
  values: image.tag=${DRONE_BRANCH}-${DRONE_COMMIT_SHA:0:7}
  prefix: PROD
  tiller_ns: operations
  when:
    branch: [master]
```

There's an option to do a `dry-run` in case you want to verify that the secrets and envvars are replaced correctly. Just add the attribute `dry-run` to true:

```YAML
pipeline_production:
  helm_deploy:
  image: quay.io/ipedrazas/drone-helm
  skip_tls_verify: true
  chart: ./charts/my-chart
  release: ${DRONE_BRANCH}
  values: image.tag=${DRONE_BRANCH}-${DRONE_COMMIT_SHA:0:7}
  prefix: STAGING
  dry-run:true
  when:
    branch: [master]
```
Happy Helming!
