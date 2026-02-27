import ..config as c
import yaml

spec = c.oathkeeper.spec

_authenticators = {}
if spec.authenticators?.jwt:
    _jwt = {enabled = spec.authenticators.jwt?.enabled or True}
    if spec.authenticators.jwt?.jwksUrls:
        _jwt |= {config = {jwks_urls = spec.authenticators.jwt.jwksUrls}}
    if spec.authenticators.jwt?.scopeStrategy:
        _jwtConfig = _jwt.get("config", {})
        _jwtConfig |= {scope_strategy = spec.authenticators.jwt.scopeStrategy}
        _jwt |= {config = _jwtConfig}
    _authenticators |= {jwt = _jwt}
if spec.authenticators?.anonymous:
    _authenticators |= {anonymous = {enabled = spec.authenticators.anonymous?.enabled or True}}
if spec.authenticators?.cookieSession:
    _cs = {enabled = spec.authenticators.cookieSession?.enabled or True}
    _csConfig = {}
    if spec.authenticators.cookieSession?.checkSessionUrl:
        _csConfig |= {check_session_url = spec.authenticators.cookieSession.checkSessionUrl}
    if spec.authenticators.cookieSession?.preservePath != None:
        _csConfig |= {preserve_path = spec.authenticators.cookieSession.preservePath}
    if spec.authenticators.cookieSession?.extraFrom:
        _csConfig |= {extra_from = spec.authenticators.cookieSession.extraFrom}
    if spec.authenticators.cookieSession?.subjectFrom:
        _csConfig |= {subject_from = spec.authenticators.cookieSession.subjectFrom}
    if _csConfig:
        _cs |= {config = _csConfig}
    _authenticators |= {cookie_session = _cs}

_authorizers = {}
if spec.authorizers?.allow:
    _authorizers |= {allow = {enabled = spec.authorizers.allow?.enabled or True}}
if spec.authorizers?.deny:
    _authorizers |= {deny = {enabled = spec.authorizers.deny?.enabled or True}}
if spec.authorizers?.remoteJson:
    _rj = {enabled = spec.authorizers.remoteJson?.enabled or True}
    _rjConfig = {}
    if spec.authorizers.remoteJson?.remote:
        _rjConfig |= {remote = spec.authorizers.remoteJson.remote}
    if spec.authorizers.remoteJson?.payload:
        _rjConfig |= {payload = spec.authorizers.remoteJson.payload}
    if _rjConfig:
        _rj |= {config = _rjConfig}
    _authorizers |= {remote_json = _rj}

_mutators = {}
if spec.mutators?.noop:
    _mutators |= {noop = {enabled = spec.mutators.noop?.enabled or True}}
if spec.mutators?.header:
    _hdr = {enabled = spec.mutators.header?.enabled or True}
    if spec.mutators.header?.headers:
        _hdr |= {config = {headers = spec.mutators.header.headers}}
    _mutators |= {header = _hdr}

_accessRulesYaml = yaml.encode([{
    id = rule.id
    upstream = {url = rule.upstreamUrl}
    match = {url = rule.matchUrl, methods = rule.matchMethods}
    authenticators = [{handler = a.handler} for a in rule.authenticators]
    authorizer = {handler = rule.authorizer.handler}
    mutators = [{handler = m.handler} for m in rule.mutators]
} for rule in spec.accessRules]) if spec.accessRules else ""

_proxyIngress = {enabled = False}
if spec.ingress?.proxy:
    _pi = {enabled = spec.ingress.proxy?.enabled if spec.ingress.proxy?.enabled != None else True}
    if spec.ingress.proxy?.className:
        _pi |= {className = spec.ingress.proxy.className}
    if spec.ingress.proxy?.annotations:
        _pi |= {annotations = spec.ingress.proxy.annotations}
    if spec.ingress.proxy?.hosts:
        _pi |= {hosts = [{
            host = h.hostname
            paths = [{path = h.path or "/", pathType = h.pathType or "Prefix"}]
        } for h in spec.ingress.proxy.hosts]}
    if spec.ingress.proxy?.tls:
        _pi |= {tls = [{secretName = t.secretName, hosts = t.hosts} for t in spec.ingress.proxy.tls]}
    _proxyIngress = _pi

_values = {
    oathkeeper = {
        config = {
            if _authenticators:
                authenticators = _authenticators
            if _authorizers:
                authorizers = _authorizers
            if _mutators:
                mutators = _mutators
            serve = {
                proxy = {port = spec.serve?.proxyPort or 4455}
                api = {port = spec.serve?.apiPort or 4456}
            }
        }
        if _accessRulesYaml:
            accessRules = _accessRulesYaml
    }
    ingress = {proxy = _proxyIngress}
}

helmRelease = {
    apiVersion = "helm.toolkit.fluxcd.io/v2"
    kind = "HelmRelease"
    metadata = {
        name = c.makeName("release")
        namespace = c.oathkeeper.metadata.namespace
        labels = c.ownerLabels
    }
    spec = {
        interval = "1h"
        chart = {
            spec = {
                chart = "oathkeeper"
                version = spec.chart?.version or "0.45.1"
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
