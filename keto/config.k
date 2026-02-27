import ..lib.input as i
import .model as m
import ..lib.utils

keto: m.Keto = i.parent

ownerLabels = utils.makeOwnerLabels(utils.OwnerLabels {
    application = "keto"
    instance = keto.metadata.name
    component = "auth"
    partOf = keto.metadata.labels?["app.kubernetes.io/part-of"]
    extra = utils.makeResourceLabels("ketoes.auth.versa-stack.io", keto.metadata.name, keto.metadata.namespace)
})

makeName = lambda name: str -> str {
    hashedParentName = utils.shortHash(keto.metadata.name)
    "keto-${hashedParentName}-${name}"
}
