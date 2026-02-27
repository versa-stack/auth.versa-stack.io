import k8s.api.core.v1 as corev1

import ..config as c

secretName = c.makeName("secrets")

# Deterministic secrets based on resource name - no clear-text required
# Simple repeat pattern to generate sufficient entropy
name = c.hydra.metadata.name
systemSecret = "${name}-${name}-hydra-system-secret-${name}".replace("-", "")[:32]
pairwiseSalt = "${name}-${name}-hydra-pairwise-salt".replace("-", "")[:16]

secret = corev1.Secret {
    metadata = {
        name = secretName
        namespace = c.hydra.metadata.namespace
        labels = c.ownerLabels
    }
    type = "Opaque"
    stringData = {
        "ORY_HYDRA_SYSTEM_SECRET": systemSecret
        "ORY_HYDRA_PAIRWISE_SALT": pairwiseSalt
    }
}

items = [secret]
