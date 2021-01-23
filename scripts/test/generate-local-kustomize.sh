#!/bin/bash

rm ../apps/k8s/kustomization.yaml
(cd ../apps/k8s && kustomize create --autodetect --recursive .)
(cd ../apps/k8s/ && sed -i -E '/base|cloud/d' kustomization.yaml)