FROM alpine:latest
MAINTAINER Ivan Pedrazas <ipedrazas@gmail.com>


RUN apk -Uuv add curl bash && rm /var/cache/apk/*

#WORKS:
ENV VERSION v2.2.0

# Does not support the --tiller-namespace option to upgrade command!
#ENV VERSION v2.1.3

ENV FILENAME helm-${VERSION}-linux-amd64.tar.gz
ENV KUBECTL v1.5.2

ADD http://storage.googleapis.com/kubernetes-helm/${FILENAME} /tmp

ADD https://storage.googleapis.com/kubernetes-release/release/${KUBECTL}/bin/linux/amd64/kubectl /tmp


RUN tar -zxvf /tmp/${FILENAME} -C /tmp \
  && mv /tmp/linux-amd64/helm /bin/helm \
  && chmod +x /tmp/kubectl \
  && mv /tmp/kubectl /bin/kubectl \
  && rm -rf /tmp

LABEL description="Kubeclt and Helm."
LABEL base="alpine"
LABEL language="python"


COPY drone-helm /bin/drone-helm
COPY kubeconfig /root/.kube/kubeconfig

ENTRYPOINT [ "/bin/drone-helm" ]
