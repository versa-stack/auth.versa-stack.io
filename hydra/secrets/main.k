import ..config as c

spec = c.hydra.spec
secretName = c.makeName("secrets")

# Reference existing secrets via SecretConfig - no clear-text required
secretEnv = [
    e for e in [
        {
            name = "ORY_HYDRA_SYSTEM_SECRET"
            valueFrom = {secretKeyRef = {name = spec.secrets.systemSecretRef.name, key = spec.secrets.systemSecretRef.keys["systemSecret"]}}
        } if spec.secrets?.systemSecretRef else None
        {
            name = "ORY_HYDRA_PAIRWISE_SALT"
            valueFrom = {secretKeyRef = {name = spec.secrets.pairwiseSaltRef.name, key = spec.secrets.pairwiseSaltRef.keys["pairwiseSalt"]}}
        } if spec.secrets?.pairwiseSaltRef else None
    ] if e
]

items = []
