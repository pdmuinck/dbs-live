<template>
<div class="source-control-panel">
  <div id="create-branch" v-if="!this.isBranchCreating">
    <font-awesome-icon class="arrow-icon" @click="setShowCreateBranch()" :icon="this.showCreateBranchBlock ? 'angle-down' : 'angle-right'" size="xs"/>
    <div class="source-control-title" @click="setShowCreateBranch()">CREATE BRANCH</div>
    <div v-if="this.showCreateBranchBlock">
      <textarea
          class="git-message-box"
          v-model="newBranchName"
          ref="textarea"
          rows="1"
          placeholder="Provide a name and hit ENTER to create"
          @focus="resize"
          @keyup="resize"
          @keyup.enter="createBranch()"
      ></textarea>
    </div>
  </div>
  <div v-if="this.isBranchCreating">
    <span>CREATING BRANCH...</span>
    <font-awesome-icon icon="spinner" class="faa-spin animated" />
  </div>
  <div id="change-list" v-if="!this.isPushing">
    <font-awesome-icon class="arrow-icon" :icon="this.showChangeList ? 'angle-down' : 'angle-right'" size="xs"/>
    <div class="source-control-title">SOURCE CONTROL</div>
    <label class="branch-label">Current branch: {{this.currentBranch}}</label>
    <textarea
        class="git-message-box"
        v-model="gitCommitMessage"
        ref="textarea"
        rows="3"
        placeholder="Provide a message and hit ENTER to commit and push"
        @focus="resize"
        @keyup="resize"
        @keyup.enter="gitCommit()"
    >
  </textarea>
    <div v-if="!isCommitMessageProvided" style="color: red;">Please provide a non empty message.</div>
    <div class="branch-label">{{gitLogs}}</div>
    <input type="checkbox" @click="selectAll">
    <font-awesome-icon class="file-operation" icon="rotate-left" size="xs" @click="revertSelectedChanges" />
    <label class="branch-label">Changes:</label>
    <div v-for="change in this.changeList" :key="change.fileName">
      <input type="checkbox" :name="change.fileName" :value="change" v-model="this.selectedFiles">
      <div class="staged-file" :class="{'deleted-file': change.status === 'D'}">{{change.fileName.split('/').slice(-1)[0]}}</div>
      <div class="staged-file-path">{{change.fileName.split('/').slice(2, -1).join('/')}}</div>
      <div class="file-status" :class="{modified: change.status === 'M', deleted: change.status === 'D', added: change.status === 'A'}">{{change.status}}</div>
    </div>

    <a  :href="pullRequestLink" v-if="pullRequestLink !== ''" target="_blank"><button class="pull-request-button">Create pull request</button></a>
  </div>
  <div v-if="this.isPushing">
    <span>PUSHING...</span>
    <font-awesome-icon icon="spinner" class="faa-spin animated" />
  </div>

</div>
</template>

<style>


.staged-file-path {
  text-overflow: ellipsis;
  overflow: hidden;
  width: 160px;
  white-space: nowrap;
  display: inline-block;
  vertical-align: bottom;
}

.pull-request-button:hover {
  background: blue;
  color: white;
  cursor: pointer;

}

.pull-request-button {
  margin-top: 10%;

}

#change-list {
  border-top: 1px solid gray;
}

.branch-label {
  display: block;
}

.source-control-title {
  margin-left: 2%;
  display: inline;
}

.source-control-title:hover, .arrow-icon:hover {
  cursor: pointer;
}

.deleted-file {
  text-decoration: line-through;
}

.git-message-box {
  outline: none;
  resize: none;
  display: block;
  margin: auto;
  width:85%;
  margin-top: 2%;
  margin-bottom: 5%;
}

body {
  font-size: 12px;
}

.added {
  color: green;
}

.modified {
  color: orange;
}

.deleted {
  color: red;
}


.file-status {
  display: inline-block;
  font-size: 12px;
  left: 5%;
}

.staged-file {
  display: inline-block;
  font-size: 12px;
  margin-left: 2%;
  max-width: 30%;
  min-width: 30%;
  vertical-align: center;
}

.staged-file:hover {
  cursor: pointer;
}

.source-control-panel {
  margin-left: 5px;
  margin-right: 5px;
  margin-top: 10px;
}

.source-control-panel > button, select {
  margin-bottom: 15px;
  margin-top: 15px;
}

.source-control-panel > li {
  list-style: none;
  margin-left: 4px;
}
</style>

<script lang="ts">
import {
  commitAndPush, createBranch,
  getBranches,
  getChangeList,
  revertChanges
} from "../composables/useApi";
import {ref} from "vue";

export default {
  emits: ["update-file-content", "new-branch", "branch-creating", "branch-created", "close-file-opened"],
  components: { },
  props: {
    currentBranch: String,
    workspace: String,
    isBranchCreating: Boolean,
    fileOpened: String
  },
  async setup(props) {
    let changeList = []
    if(!props.isBranchCreating) {
      if(props.currentBranch) {
        changeList = await getChangeList(props.workspace, props.currentBranch).then(response => response.data.filter(change => change.status !== 'AD'))
      } else {
        const branches = await getBranches(props.workspace).then(response => response.data.branches)
        changeList = await getChangeList(props.workspace, branches[0]).then(response => response.data.filter(change => change.status !== 'AD'))
      }
    }

    const selectedFiles = ref([])

    return {
      gitLogs: "",
      changeList: changeList,
      selectedFiles,
      showCreateBranchBlock: false,
      showChangeList: true,
      newBranchName: '',
      isPushing: false,
      gitCommitMessage: '',
      isCommitMessageProvided: true,
      pullRequestLink: '',
      selectAllChanges: false
    };
  },

  methods: {

    selectAll(){
      this.selectAllChanges = !this.selectAllChanges
      if(this.selectAllChanges) {
        this.selectedFiles = this.changeList
      } else {
        this.selectedFiles = []
      }
    },

    async createBranch() {
      this.showCreateBranchBlock = false
      this.$emit('branch-creating')
      this.$forceUpdate()
      const dirTree = await createBranch(this.workspace, this.newBranchName.replace(/(\r\n|\n|\r)/gm, "")).then(response => response.data)
      this.newBranchName = ''
      this.$emit('branch-created')
    },

    setShowCreateBranch() {
      this.showCreateBranchBlock = !this.showCreateBranchBlock
      this.$forceUpdate()
    },

    async gitCommit() {
      console.log(this.selectedFiles)
      this.isCommitMessageProvided = this.gitCommitMessage && this.gitCommitMessage.replace(/(\r\n|\n|\r)/gm, "") !== ""

      if(!this.isCommitMessageProvided) {
        this.$forceUpdate()
        return
      }

      this.isPushing = true
      this.$forceUpdate()
      await commitAndPush(this.workspace, this.currentBranch, this.gitCommitMessage.replace(/(\r\n|\n|\r)/gm, ""), this.selectedFiles.join(" "))
          .then(response => {
            this.changeList = response.data.changeList === "" ? [] : JSON.parse(response.data.changeList)
            if (response.data.pushSuccess === "0" && response.data.commitSuccess === "0") {
              this.gitLogs = "Push success!"
              this.pullRequestLink = response.data.pullRequestLink
            } else {
              this.gitLogs = "Something went wrong when pushing commits"
            }
          })
      this.changeList = await getChangeList(this.workspace, this.currentBranch).then(response => response.data.filter(change => change.status !== 'AD'))
      this.isPushing = false
      this.gitCommitMessage = ''
      this.$forceUpdate();
    },


    async revertSelectedChanges() {
      const newFiles = this.selectedFiles.filter(change => change.status === 'A').map(change => change.fileName).join(' ')
      const existingFiles = this.selectedFiles.filter(change => change.status !== 'A').map(change => change.fileName).join(' ')

      const changes = {"newFiles": newFiles, "existingFiles": existingFiles}
      this.changeList = await revertChanges(this.workspace, this.currentBranch, changes).then(response => response.data)
      //this.$emit('update-file-content', fileName)
      if(this.selectedFiles.filter(change => this.fileOpened.includes(change.fileName)).length > 0) {
        this.$emit('close-file-opened')
      }

      this.selectedFiles = []
      this.$forceUpdate();

    }
  }
}
</script>