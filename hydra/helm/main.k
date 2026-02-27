import ..config as c

spec = c.hydra.spec

_corsConfig = {
    enabled = spec.cors?.enabled if spec.cors else True
    if spec.cors?.allowedOrigins:
        allowed_origins = spec.cors.allowedOrigins
    if spec.cors?.allowedMethods:
        allowed_methods = spec.cors.allowedMethods
    if spec.cors?.allowedHeaders:
        allowed_headers = spec.cors.allowedHeaders
} if spec.cors else {}

_values = {
    hydra = {
        config = {
            urls = {
                self = {issuer = spec.urls.issuer}
                consent = spec.urls.consent
                login = spec.urls.login
                logout = spec.urls.logout
            }
            if spec.secrets:
                secrets = {
                    if spec.secrets.systemSecretRef:
                        system = {
                            existingSecret = spec.secrets.systemSecretRef.name
                            existingSecretKey = spec.secrets.systemSecretRef.keys["systemSecret"]
                        }
                    if spec.secrets.pairwiseSaltRef:
                        pairwise = {
                            existingSecret = spec.secrets.pairwiseSaltRef.name
                            existingSecretKey = spec.secrets.pairwiseSaltRef.keys["pairwiseSalt"]
                        }
                }
            if spec.oidc:
                oidc = {
                    subject_identifiers = {
                        supported_types = spec.oidc?.subjectIdentifiers?.supportedTypes or ["public"]
                        if spec.oidc?.subjectIdentifiers?.pairwiseSalt:
                            pairwise = {salt = spec.oidc.subjectIdentifiers.pairwiseSalt}
                    }
                }
            if _corsConfig:
                serve = {public = {cors = _corsConfig}}
        }
    }
    ingress = {
        public = _makeIngress(spec.ingress?.public) if spec.ingress?.public else {enabled = False}
        admin = _makeIngress(spec.ingress?.admin) if spec.ingress?.admin else {enabled = False}
    }
}

_makeIngress = lambda ing: any -> any {
    {
        enabled = ing.enabled if ing.enabled != None else True
        if ing.className:
            className = ing.className
        if ing.hostname:
            hosts = [{
                host = ing.hostname
                paths = [{path = ing.path or "/", pathType = ing.pathType or "Prefix"}]
            }]
        if ing.annotations:
            annotations = ing.annotations
        if ing.tls:
            tls = [{secretName = ing.tls.secretName, hosts = [ing.hostname]}]
    }
}

helmRepository = {
    apiVersion = "source.toolkit.fluxcd.io/v1"
    kind = "HelmRepository"
    metadata = {
        name = "ory"
        namespace = "flux-system"
        labels = c.ownerLabels
    }
    spec = {
        interval = "1h"
        url = "https://k8s.ory.sh/helm/charts"
    }
}

helmRelease = {
    apiVersion = "helm.toolkit.fluxcd.io/v2"
    kind = "HelmRelease"
    metadata = {
        name = c.makeName("release")
        namespace = c.hydra.metadata.namespace
        labels = c.ownerLabels
    }
    spec = {
        interval = "1h"
        chart = {
            spec = {
                chart = "hydra"
                version = spec.chart?.version or "0.40.1"
                sourceRef = {
                    kind = "HelmRepository"
                    name = "ory"
                    namespace = "flux-system"
                }
            }
        }
        values = _values | (spec.chart?.valuesOverride or {})
    }
}

items = [helmRepository, helmRelease]
