<template>
  <ul>
    <div v-if="!this.isRenameFile" :class="{selected: isActiveItem, 'file-name': true}" @click="oneClickMethod(this.node)">
      <font-awesome-icon  :icon="this.showChildren ? 'angle-down' : 'angle-right'" size="xs" v-if="children"/>
      <span>{{name}}</span>
      <div class="file-operations file-operations-selected">
        <font-awesome-icon v-if="isActiveItem && isFolder" class="file-operation" icon="file-circle-plus" size="s" @click="startCreateFile()" />
        <font-awesome-icon v-if="isActiveItem && isFolder" class="file-operation" icon="folder-plus" size="s" @click="startCreateFolder()" />
        <font-awesome-icon v-if="isActiveItem" class="file-operation" icon="file-circle-xmark" size="s" @click="deleteObject()" />
        <font-awesome-icon v-if="isActiveItem" class="file-operation" icon="file-edit" size="s" @click="prepRename()" />
      </div>
    </div>
    <input
        class="edit-file-name"
        v-if="this.isRenameFile"
        v-model="name"
        @keyup.enter="renameFile(name)" @keyup.esc="setRenameFile"/>
      <input
          class="edit-file-name"
          v-if="isNewFileAction && isActiveItem"
          v-model="fileName"
          @keyup.enter="createNewFile(fileName)"/>
      <input
          class="edit-file-name"
          v-if="isNewFolderAction && isActiveItem"
          v-model="folderName"
          @keyup.enter="createNewFolder(folderName)"/>
    <Tree :show-children="this.grandChildren" @delete-object="deleteObject" @rename-file="passRename" @new-file="createNewFile" @new-folder="createNewFolder" :current-node="this.currentNode" :node="child" :is-new-file-action="isNewFileAction" :is-new-folder-action="isNewFolderAction" :style="border" @update-active-file-content="updateSelected" :name="child.path.split('/').slice(-1)[0]" :path="child.path" :children="child.children" v-if="showChildren" :depth="depth + 1" v-for="child in children"/>
  </ul>
</template>

<script lang="ts">

export default {
  emits: ['update-active-file-content', 'new-file', 'rename-file', 'delete-object', 'new-folder', 'create-new-file', 'create-new-folder'],
  name: "Tree",
  props: {
    name: String,
    children: Array,
    depth: Number,
    path: String,
    node: Object,
    currentNode: Object,
    showChildren: false
  },
  data(props) {
    return {isDeleteObject: false, isNewFileAction: false, isNewFolderAction: false, showChildren: false, folderName: '', oldPath: '', isRenameFile: false, clicks: 0, timer: null, delay: 200}
  },
  computed: {

      border() {
        return {'border-left': '0.5px solid gray', 'margin-left': '4px', 'padding-left': '10px'}
      },
      isActiveItem() {
        return this.node.path === this.currentNode.path
    },
    isFolder(){
      return this.node.type == 'directory'
    }
  },
  methods: {

    setRenameFile() {
      this.isRenameFile = false
      this.$forceUpdate()
    },

    passRename(renameObject) {
      this.$emit('rename-file', renameObject)
    },

    prepRename() {
      this.oldPath = this.path
      this.isRenameFile = true
      this.$forceUpdate()
    },

    renameFile(fileName) {
      this.isRenameFile = false
      const newPath = this.path.split('/').slice(0, -1).join("/") + "/" + this.name.replace(/(\r\n|\n|\r)/gm, "")
      this.$emit('rename-file', {"new": newPath, "old": this.oldPath})
    },

    createNewFolder(folderName) {
      this.$emit('new-folder', folderName.replace(/(\r\n|\n|\r)/gm, ""))
      this.isNewFolderAction = false
    },
    createNewFile(fileName) {
      this.showChildren = true
      this.$emit('new-file', fileName.replace(/(\r\n|\n|\r)/gm, ""))
      this.isNewFileAction = false
    },

    deleteObject() {
      this.$emit('delete-object')
      this.$forceUpdate()
    },

    startCreateFile() {
      this.fileName = ''
      this.folderName = ''
      this.isNewFileAction = true
      this.isNewFolderAction = false
    },

    startCreateFolder() {
      this.folderName = ''
      this.fileName = ''
      this.isNewFileAction = false
      this.isNewFolderAction = true
    },

    oneClickMethod() {
      console.log('click')
      console.log(this.isDeleteObject)
      if(!this.isNewFileAction && !this.isNewFolderAction && !this.isRenameFile && !this.isDeleteObject) {
        this.showChildren = !this.showChildren
        this.updateSelected(this.node)
      }
    },

    updateSelected: function (node) {
      this.isRenameFile = false
      this.isNewFileAction = false
      this.isNewFolderAction = false
      this.isDeleteObject = false
      this.$emit('update-active-file-content', node );
    },


  }
};
</script>

<style>

.edit-file-name {
  width: 100%;
  margin: 1%;
}

.file-name {
  font-size: 13px;
}

.file-name > span {
  margin-left: 5px;
}

.file-name:hover {
  background: aliceblue;
}

textarea {
  outline: none;
  resize: none;
}

ul {
  width: 97%;
}

.selected, .selected:hover {
  background-color: darkblue;
  color: white;
}


.hidden {
  display: block;
}

.file-operation {
  margin-left: 3px;
  cursor: pointer;
  color: gray;
}
.file-operation:hover {
  color: white;
}

.file-operations {
  display: inline;
  margin-right: 5%;
  float: right;
}

</style>