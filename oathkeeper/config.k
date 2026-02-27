import ..lib.input as i
import .model as m
import ..lib.utils

oathkeeper: m.Oathkeeper = i.parent

ownerLabels = utils.makeOwnerLabels(utils.OwnerLabels {
    application = "oathkeeper"
    instance = oathkeeper.metadata.name
    component = "auth"
    partOf = oathkeeper.metadata.labels?["app.kubernetes.io/part-of"]
    extra = utils.makeResourceLabels("oathkeepers.auth.versa-stack.io", oathkeeper.metadata.name, oathkeeper.metadata.namespace)
})

makeName = lambda name: str -> str {
    hashedParentName = utils.shortHash(oathkeeper.metadata.name)
    "oathkeeper-${hashedParentName}-${name}"
}
