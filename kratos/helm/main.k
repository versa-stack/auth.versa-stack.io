import ..config as c

spec = c.kratos.spec

_corsConfig = {
    enabled = spec.cors?.enabled if spec.cors else True
    if spec.cors?.allowedOrigins:
        allowed_origins = spec.cors.allowedOrigins
} if spec.cors else {}

_flows = {}
if spec.selfservice?.flows?.loginUiUrl:
    _flows |= {login = {ui_url = spec.selfservice.flows.loginUiUrl}}
if spec.selfservice?.flows?.registrationUiUrl:
    _flows |= {registration = {ui_url = spec.selfservice.flows.registrationUiUrl, enabled = spec.selfservice.flows?.registrationEnabled or True}}
if spec.selfservice?.flows?.verificationUiUrl:
    _flows |= {verification = {ui_url = spec.selfservice.flows.verificationUiUrl, enabled = spec.selfservice.flows?.verificationEnabled or True}}
if spec.selfservice?.flows?.recoveryUiUrl:
    _flows |= {recovery = {ui_url = spec.selfservice.flows.recoveryUiUrl, enabled = spec.selfservice.flows?.recoveryEnabled or True}}
if spec.selfservice?.flows?.settingsUiUrl:
    _flows |= {settings = {ui_url = spec.selfservice.flows.settingsUiUrl}}

_values = {
    kratos = {
        config = {
            serve = {
                public = {
                    base_url = spec.serve.publicBaseUrl
                    if _corsConfig:
                        cors = _corsConfig
                }
                if spec.serve?.adminBaseUrl:
                    admin = {base_url = spec.serve.adminBaseUrl}
            }
            if spec.selfservice:
                selfservice = {
                    if spec.selfservice?.defaultBrowserReturnUrl:
                        default_browser_return_url = spec.selfservice.defaultBrowserReturnUrl
                    if _flows:
                        flows = _flows
                    if spec.selfservice?.methods:
                        methods = {
                            if spec.selfservice.methods?.password != None:
                                password = {enabled = spec.selfservice.methods.password}
                        }
                }
            if spec.identity:
                identity = {
                    default_schema_id = spec.identity?.defaultSchemaId or "default"
                    if spec.identity?.schemas:
                        schemas = [{id = s.id, url = s.url} for s in spec.identity.schemas]
                }
            secrets = {
                cookie = [spec.secrets.cookie]
                if spec.secrets?.cipher:
                    cipher = [spec.secrets.cipher]
            }
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

helmRelease = {
    apiVersion = "helm.toolkit.fluxcd.io/v2"
    kind = "HelmRelease"
    metadata = {
        name = c.makeName("release")
        namespace = c.kratos.metadata.namespace
        labels = c.ownerLabels
    }
    spec = {
        interval = "1h"
        chart = {
            spec = {
                chart = "kratos"
                version = spec.chart?.version or "0.50.1"
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
