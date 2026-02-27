import k8s.api.core.v1 as corev1

import ..config as c

spec = c.hydra.spec
secretName = c.makeName("secrets")

_secretData = {}
if spec.secrets?.system:
    _secretData |= {"ORY_HYDRA_SYSTEM_SECRET": spec.secrets.system}
if spec.secrets?.pairwiseSalt:
    _secretData |= {"ORY_HYDRA_PAIRWISE_SALT": spec.secrets.pairwiseSalt}

secret = corev1.Secret {
    metadata = {
        name = secretName
        namespace = c.hydra.metadata.namespace
        labels = c.ownerLabels
    }
    type = "Opaque"
    stringData = _secretData
} if _secretData else None

items = [secret] if secret else []
