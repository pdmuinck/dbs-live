

export function getDbtProjectsFromDirectoryTree(tree) {
  return tree.children.filter(child => child.path.indexOf('project_') !== -1)
    .map(node => node.children).map(child => child.filter(node => node.path.indexOf('dbt') !== -1))
    .map(node => node[0].children.filter(child => child.path.split('/').slice(-1)[0].indexOf('project_') !== -1))
    .flatMap(x => x)
}

export function getNodeFromTree(tree, path) {
  if(tree && path) {
    if(tree.path === path) return tree
    let foundTree
    if(tree.children) {
      foundTree = tree.children.map(child => getNodeFromTree(child, path)).filter(x => x)[0]
    }
    return foundTree
  }
}


