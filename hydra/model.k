import ..lib.model as _libm
import k8s.apimachinery.pkg.apis.meta.v1 as metav1

schema Hydra:
    apiVersion: str = "auth.versa-stack.io/v1alpha1"
    kind: str = "Hydra"
    metadata: metav1.ObjectMeta
    spec: HydraSpec

schema HydraSpec:
    chart?: _libm.HelmChartConfig
    urls?: HydraUrls
    oidc?: HydraOidc
    cors?: _libm.CorsConfig
    ingress?: HydraIngress
    database?: _libm.DatabaseConfig

schema HydraUrls:
    issuer: str
    consent: str
    login: str
    logout: str

schema HydraOidc:
    subjectIdentifiers?: HydraSubjectIdentifiers

schema HydraSubjectIdentifiers:
    supportedTypes?: [str]
    pairwiseSalt?: str

schema HydraIngress:
    public?: _libm.IngressConfig
    admin?: _libm.IngressConfig
