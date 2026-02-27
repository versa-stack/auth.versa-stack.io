import k8s.api.core.v1 as corev1

import ..config as c

spec = c.kratos.spec
secretName = c.makeName("secrets")

_secretData = {}
if spec.secrets?.cookie:
    _secretData |= {"ORY_KRATOS_COOKIE_SECRET": spec.secrets.cookie}
if spec.secrets?.cipher:
    _secretData |= {"ORY_KRATOS_CIPHER_SECRET": spec.secrets.cipher}

secret = corev1.Secret {
    metadata = {
        name = secretName
        namespace = c.kratos.metadata.namespace
        labels = c.ownerLabels
    }
    type = "Opaque"
    stringData = _secretData
} if _secretData else None

items = [secret] if secret else []
