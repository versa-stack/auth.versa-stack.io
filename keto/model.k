import ..lib.model as _libm
import k8s.apimachinery.pkg.apis.meta.v1 as metav1

schema Keto:
    apiVersion: str = "auth.versa-stack.io/v1alpha1"
    kind: str = "Keto"
    metadata: metav1.ObjectMeta
    spec: KetoSpec

schema KetoSpec:
    chart?: _libm.HelmChartConfig
    namespaces?: [KetoNamespace]
    serve?: KetoServe
    ingress?: KetoIngress
    database?: _libm.DatabaseConfig

schema KetoNamespace:
    id: int
    name: str

schema KetoServe:
    readHost?: str = "0.0.0.0"
    readPort?: int = 4466
    writeHost?: str = "0.0.0.0"
    writePort?: int = 4467
    metricsHost?: str = "0.0.0.0"
    metricsPort?: int = 4468

schema KetoIngress:
    read?: _libm.IngressConfig
    write?: _libm.IngressConfig
