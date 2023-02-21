<template>
  <label for="select-branch">BRANCH:</label>
  <select id="select-branch" class="select-branches" v-model="currentBranch" @change="onBranchChange">
    <option v-for="branch in branches" :value="branch" v-bind:key="branch">{{ branch }}</option>
  </select>
  <label for="select-project">PROJECT:</label>
  <select id="select-project" class="select-branches" v-model="currentProject" @change="onProjectChange">
    <option v-for="project in projects" :value="project" v-bind:key="project.path">{{ project.path.split('/').slice(-1)[0] }}</option>
  </select>

  <Tree :show-children="true" @delete-object="deleteObjectInTree()" @rename-file="renameFile" @new-file="newFile" @new-folder="newFolder" :path="currentProject.path" :node="currentProject" :currentNode="currentNode"  class="repo" @update-active-file-content="updateSelected" :name="files.path.split('/').slice(-1)[0]" :children="files.children" :depth="0"></Tree>

</template>

<style>
.repo {
  display: inline-block;
  padding: 1px;
  margin-left: 5px;
  margin-top: 5px;
  cursor: pointer;
}



.select-branches {
  margin-left: 2%;
  width: 75%;
  display: inline-block;
}

label {
  font-size: 12px;
  display: inline-block;
  margin-left: 1%;
}
</style>

<script lang="ts">
import {defineComponent, onMounted, ref} from 'vue';
import Tree from "../components/Tree.vue";
import {
  createFile,
  createFolder,
  deleteObject,
  getRepo,
  getBranches,
  getFile,
  renameObject
} from "../composables/useApi";
import {getDbtProjectsFromDirectoryTree, getNodeFromTree} from "../composables/helper";


export default defineComponent({
  emits: ['update-active-file-content', 'deleted-file', 'branch-change', 'selected-file-change', 'branches', 'current-branch'],
  components: { Tree },
  props: {
    workspace: String,
    currentBranch: String,
    isBranchCreating: Boolean,
    branches: Array
  },
  async setup(props, context) {
    let branches = []
    if(!props.isBranchCreating) {
      branches = await getBranches(props.workspace).then(response => response.data.branches)
    } else {
      branches = props.branches
    }

    let currentBranch = props.currentBranch ? props.currentBranch : branches[0]
    const repo = await getRepo(props.workspace, currentBranch).then(response => response.data)
    const projects = getDbtProjectsFromDirectoryTree(repo)

    const currentProject = projects[0]
    const files = currentProject

    let currentNode = ref(currentProject)
    context.emit('branches', branches)
    context.emit('current-branch', currentBranch)

    return { files, currentNode, branches, currentBranch, projects, currentProject };
  },

  methods: {

    async onBranchChange() {
      this.files = {path: ""}
      const repo = await getRepo(this.workspace, this.currentBranch).then(response => response.data)
      this.projects = getDbtProjectsFromDirectoryTree(repo)
      this.currentProject = this.projects[0]
      this.files = this.currentProject
      this.currentNode = ref(this.files)
      this.$emit('branch-change', this.currentBranch );
      this.$forceUpdate();
    },

    async onProjectChange() {
      this.files = this.currentProject
      this.currentNode = ref(this.files)
      this.$forceUpdate();
    },

    updateSelected: function (node: Object) {
      this.currentNode = node
      this.$emit('update-active-file-content', this.currentNode );
    },

    async newFolder(folderName: String) {
      const path = this.currentNode.path + "/" + folderName
      const response = await createFolder(path)
          .then((response) => response.data)
          .catch((err) => console.log(err));

      const repo = response.children.filter(child => child.path.indexOf(this.currentBranch) !== -1)[0]
      this.files = getDbtProjectsFromDirectoryTree(repo).filter(node => node.path === this.currentProject.path)[0]
      const newFolderNode = getNodeFromTree(this.files, path)
      this.updateSelected(newFolderNode)
      this.$forceUpdate();
    },

    async newFile(fileName: String) {
      const path = this.currentNode.path + "/" + fileName
      const content = '{{ config(\n' +
          '    materialized=\'table\',\n' +
          '    tags=["daily"],\n' +
          '    query_tag=\n' +
          '            \'{\n' +
          '                "case": "",\n' +
          '                "owner": "",\n' +
          '                "description": ""\n' +
          '            }\',\n' +
          '\t) ' +
          '\n}}'

      const response = await createFile(path, content)
          .then((response) => response.data)
          .catch((err) => console.log(err));

      const repo = response.children.filter(child => child.path.indexOf(this.currentBranch) !== -1)[0]
      this.files = getDbtProjectsFromDirectoryTree(repo).filter(node => node.path === this.currentProject.path)[0]
      const newFileNode = getNodeFromTree(this.files, path)
      this.updateSelected(newFileNode)
      this.$forceUpdate();
    },

    async renameFile(oldToNew: Object) {

      const renameResponse = await renameObject(this.workspace, this.currentBranch, oldToNew).then(response => response.data)

      const repo = renameResponse.children.filter(child => child.path.indexOf(this.currentBranch) !== -1)[0]
      this.files = getDbtProjectsFromDirectoryTree(repo).filter(node => ('/' + node.path) === this.currentProject.path)[0]
      const newFileNode = getNodeFromTree(this.files, oldToNew.new.substring(1))
      this.updateSelected(newFileNode)
      this.$forceUpdate();
      this.$emit('selected-file-change', oldToNew.new)
    },

    async deleteObjectInTree(){

      const parent = this.currentNode.path.split('/').slice(0,-1).join('/')

      const repo = await deleteObject(this.currentNode.path)
          .then((response) => response.data)
          .catch((err) => console.log(err));

      this.$emit('deleted-file', this.currentNode);

      const branchTree = repo.children.filter(node => node.path.indexOf(this.currentBranch) !== -1)[0]
      this.files = getDbtProjectsFromDirectoryTree(branchTree).filter(node => node.path === this.currentProject.path)[0]
      const parentNode = getNodeFromTree(this.files, parent)
      this.updateSelected(parentNode)
      this.$forceUpdate();
    }
  }
});
</script>