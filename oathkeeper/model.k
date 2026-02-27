import ..lib.model as _libm
import k8s.apimachinery.pkg.apis.meta.v1 as metav1

schema Oathkeeper:
    apiVersion: str = "auth.versa-stack.io/v1alpha1"
    kind: str = "Oathkeeper"
    metadata: metav1.ObjectMeta
    spec: OathkeeperSpec

schema OathkeeperSpec:
    chart?: _libm.HelmChartConfig
    authenticators?: OathkeeperAuthenticators
    authorizers?: OathkeeperAuthorizers
    mutators?: OathkeeperMutators
    serve?: OathkeeperServe
    accessRules?: [OathkeeperAccessRule]
    ingress?: OathkeeperIngress

schema OathkeeperAuthenticators:
    jwt?: OathkeeperJwtAuth
    anonymous?: OathkeeperToggle
    cookieSession?: OathkeeperCookieSession

schema OathkeeperJwtAuth:
    enabled?: bool = True
    jwksUrls?: [str]
    scopeStrategy?: str = "exact"

schema OathkeeperCookieSession:
    enabled?: bool = True
    checkSessionUrl?: str
    preservePath?: bool = True
    extraFrom?: str
    subjectFrom?: str

schema OathkeeperToggle:
    enabled?: bool = True

schema OathkeeperAuthorizers:
    allow?: OathkeeperToggle
    deny?: OathkeeperToggle
    remoteJson?: OathkeeperRemoteJsonAuthorizer

schema OathkeeperRemoteJsonAuthorizer:
    enabled?: bool = True
    remote?: str
    payload?: str

schema OathkeeperMutators:
    noop?: OathkeeperToggle
    header?: OathkeeperHeaderMutator

schema OathkeeperHeaderMutator:
    enabled?: bool = True
    headers?: {str:str}

schema OathkeeperServe:
    proxyPort?: int = 4455
    apiPort?: int = 4456

schema OathkeeperAccessRule:
    id: str
    upstreamUrl: str
    matchUrl: str
    matchMethods: [str]
    authenticators: [OathkeeperRuleHandler]
    authorizer: OathkeeperRuleHandler
    mutators: [OathkeeperRuleHandler]

schema OathkeeperRuleHandler:
    handler: str

schema OathkeeperIngress:
    proxy?: OathkeeperProxyIngress

schema OathkeeperProxyIngress:
    enabled?: bool = True
    className?: str
    annotations?: {str:str}
    hosts?: [OathkeeperProxyIngressHost]
    tls?: [OathkeeperProxyIngressTls]

schema OathkeeperProxyIngressHost:
    hostname: str
    path?: str = "/"
    pathType?: str = "Prefix"

schema OathkeeperProxyIngressTls:
    secretName: str
    hosts: [str]
