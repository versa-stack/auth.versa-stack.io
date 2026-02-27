import ..config as c

spec = c.keto.spec

_values = {
    keto = {
        config = {
            if spec.namespaces:
                namespaces = [{id = ns.id, name = ns.name} for ns in spec.namespaces]
            serve = {
                read = {
                    host = spec.serve?.readHost or "0.0.0.0"
                    port = spec.serve?.readPort or 4466
                }
                write = {
                    host = spec.serve?.writeHost or "0.0.0.0"
                    port = spec.serve?.writePort or 4467
                }
                metrics = {
                    host = spec.serve?.metricsHost or "0.0.0.0"
                    port = spec.serve?.metricsPort or 4468
                }
            }
        }
    }
    ingress = {
        read = _makeIngress(spec.ingress?.read) if spec.ingress?.read else {enabled = False}
        write = _makeIngress(spec.ingress?.write) if spec.ingress?.write else {enabled = False}
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

helmRelease = {
    apiVersion = "helm.toolkit.fluxcd.io/v2"
    kind = "HelmRelease"
    metadata = {
        name = c.makeName("release")
        namespace = c.keto.metadata.namespace
        labels = c.ownerLabels
    }
    spec = {
        interval = "1h"
        chart = {
            spec = {
                chart = "keto"
                version = spec.chart?.version or "0.12.1"
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

items = [helmRelease]
