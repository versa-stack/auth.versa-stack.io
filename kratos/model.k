import ..lib.model as _libm
import k8s.apimachinery.pkg.apis.meta.v1 as metav1

schema Kratos:
    apiVersion: str = "auth.versa-stack.io/v1alpha1"
    kind: str = "Kratos"
    metadata: metav1.ObjectMeta
    spec: KratosSpec

schema KratosSpec:
    chart?: _libm.HelmChartConfig
    serve?: KratosServe
    selfservice?: KratosSelfservice
    identity?: KratosIdentity
    secrets?: KratosSecrets
    cors?: _libm.CorsConfig
    ingress?: KratosIngress
    database?: _libm.DatabaseConfig

schema KratosServe:
    publicBaseUrl: str
    adminBaseUrl?: str

schema KratosSelfservice:
    defaultBrowserReturnUrl?: str
    flows?: KratosFlows
    methods?: KratosMethods

schema KratosFlows:
    loginUiUrl?: str
    registrationUiUrl?: str
    registrationEnabled?: bool = True
    verificationUiUrl?: str
    verificationEnabled?: bool = True
    recoveryUiUrl?: str
    recoveryEnabled?: bool = True
    settingsUiUrl?: str

schema KratosMethods:
    password?: bool = True

schema KratosIdentity:
    defaultSchemaId?: str = "default"
    schemas?: [KratosIdentitySchema]

schema KratosIdentitySchema:
    id: str
    url: str

schema KratosSecrets:
    cookie: str
    cipher?: str

schema KratosIngress:
    public?: _libm.IngressConfig
    admin?: _libm.IngressConfig
