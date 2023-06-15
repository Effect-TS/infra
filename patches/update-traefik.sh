#!/bin/sh
helm install -n traefik traefik-internal traefik/traefik --values traefik-internal-values.yaml
helm install -n traefik traefik-external traefik/traefik --values traefik-external-values.yaml
