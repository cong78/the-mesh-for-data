#!/usr/bin/env bash

set -e
set -x

: ${WITHOUT_OPENSHIFT:=true}
: ${DONOT_DELETE_PERSISTENT_STORAGE:=false}

NAMESPACE=egeria-catalog
TIMEOUT=8m
VERSION="egeria-release-2.6"


undeploy() {
        # scc permissions for egeria pods to execute
        # this is done as per guidelines mentioned in https://github.com/odpi/egeria/issues/2790#issuecomment-674879248
        $WITHOUT_OPENSHIFT || oc delete securitycontextconstraints --ignore-not-found egeria-restricted

        rm -rf egeria
        helm delete egeria --namespace=$NAMESPACE --timeout=${TIMEOUT} 2>/dev/null || true
        result=$(kubectl get pvc --namespace=$NAMESPACE -o=jsonpath='{.items..metadata.name}')
        $DONOT_DELETE_PERSISTENT_STORAGE || kubectl delete pvc --namespace=$NAMESPACE $result 2>/dev/null || true
}

deploy() {
        helm repo add bitnami https://charts.bitnami.com/bitnami
        helm repo update

        rm -rf egeria
        git clone \
            --depth=1 \
            --branch=$VERSION \
            --filter=blob:none \
            https://github.com/odpi/egeria.git

        # create the ns if it doesn't exist
        kubectl create ns $NAMESPACE || true

        # scc permissions for egeria pods to execute
        # this is done as per guidelines mentioned in https://github.com/odpi/egeria/issues/2790#issuecomment-674879248
        $WITHOUT_OPENSHIFT || oc adm policy add-scc-to-group anyuid system:authenticated
        $WITHOUT_OPENSHIFT || oc create -f egeria-scc.yaml
        $WITHOUT_OPENSHIFT || oc adm policy add-scc-to-user egeria-restricted -z default -n $NAMESPACE

        cd egeria/open-metadata-resources/open-metadata-deployment/charts
        helm dep update egeria-base
        helm install egeria egeria-base --namespace=$NAMESPACE
        cd ../../../../
        rm -rf egeria
}

case "$1" in
    deploy)
        undeploy
        deploy
        ;;
    undeploy)
        undeploy
        ;;
    *)
        echo "usage: $0 [deploy|undeploy]"
        exit 1
        ;;
esac
