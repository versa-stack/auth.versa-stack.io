schema HelmChartConfig:
    version: str
    valuesOverride?: any

schema IngressConfig:
    enabled?: bool = False
    className?: str
    hostname?: str
    path?: str = "/"
    pathType?: str = "Prefix"
    annotations?: {str:str}
    tls?: IngressTlsConfig

schema IngressTlsConfig:
    secretName: str

schema CorsConfig:
    enabled?: bool = True
    allowedOrigins?: [str]
    allowedMethods?: [str]
    allowedHeaders?: [str]

schema DatabaseConfig:
    engine: str
    version?: str
    topology?: str
    replicas?: int = 1
    storage?: str = "10Gi"
    storageClassName?: str
    resources?: {str:{str:str}}

schema SecretConfig:
    name: str
    keys: {str:str}
