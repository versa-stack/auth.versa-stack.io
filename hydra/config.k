import ..lib.input as i
import .model as m
import ..lib.utils

hydra: m.Hydra = i.parent

ownerLabels = utils.makeOwnerLabels(utils.OwnerLabels {
    application = "hydra"
    instance = hydra.metadata.name
    component = "auth"
    partOf = hydra.metadata.labels?["app.kubernetes.io/part-of"]
    extra = utils.makeResourceLabels("hydras.auth.versa-stack.io", hydra.metadata.name, hydra.metadata.namespace)
})

makeName = lambda name: str -> str {
    hashedParentName = utils.shortHash(hydra.metadata.name)
    "hydra-${hashedParentName}-${name}"
}
