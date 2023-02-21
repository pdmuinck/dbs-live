import axios from 'axios'


/**
 * The base URL of the API, without trailing slash.
 */
const fileServerUrl = import.meta.env.VITE_FILE_SERVER_URL
const gitServerUrl = import.meta.env.VITE_GIT_SERVER_URL
const dbtServerUrl = import.meta.env.VITE_DBT_SERVER_URL


export function getFile(path) {
  return axios.get(fileServerUrl + path, {
    headers: {
      'Cache-control': 'no-cache'
    }
  })
}

export function getRepo(workspace, branch) {
  return axios.get(fileServerUrl + '/workspaces/' + workspace + '/branches/' + branch)
}

export function renameObject(workspace, branch, body) {
  return axios.post(fileServerUrl + '/workspaces/' + workspace + '/branches/' + branch + '/rename', body)
}

export function createFolder(path){
  return axios.post(fileServerUrl + path + "?type=directory", "")
}

export function createFile(path, content){
  return axios.post(fileServerUrl + path + "?type=file", content)
}

export function deleteObject(path){
  return axios.delete(fileServerUrl + path)
}

export function getBranches(workspace) {
  console.log(gitServerUrl)
  return axios.get(gitServerUrl + '/workspaces/' + workspace + '/branches')
}

export function createBranch(workspace, branchName) {
  return axios.get(gitServerUrl + '/workspaces/' + workspace + '/branches/' + branchName)
}

export function getChangeList(workspace, branch) {
  return axios.get(gitServerUrl + '/workspaces/' + workspace + '/branches/' + branch + '/changes' )
}

export function commitAndPush(workspace, branch, message, files) {
  const body = {"message": message, "files": files}
  return axios.post(gitServerUrl + '/workspaces/' + workspace + '/branches/' + branch + '/changes', body)
}

export function revertChanges(workspace, branch, body) {
  return axios.post(gitServerUrl + '/workspaces/' + workspace + '/branches/' + branch + '/revert', body )
}

export function dbtOperation(path, operation) {
  return axios.post(dbtServerUrl + path + '?dbtAction=' + operation )
}

export default {
  createFile,
  deleteObject,
  dbtOperation,
  createFolder,
  getFile,
  getRepo,
  getBranches,
  getChangeList,
  commitAndPush,
  revertChanges,
  createBranch,
  renameObject
}
