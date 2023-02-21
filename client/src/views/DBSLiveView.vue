<template>
  <div></div>
  <div class="container">
    <aside class="left-menu">
      <div @click="setExplorer" :class="{ 'menu-selected': showExplorer }">
        <font-awesome-icon :icon="['far', 'file']" inverse size="2x" :class="{'menu-item': !showExplorer, 'menu-highlighted': showExplorer}" />
      </div>
      <div @click="setShowGit" :class="{ 'menu-selected': showGit }">
        <font-awesome-icon icon="code-branch" inverse size="2x" :class="{'menu-item': !showGit, 'menu-highlighted': showGit}" />
      </div>
    </aside>
    <div class="repo-tree">
      <Suspense v-if="this.showExplorer">
        <template #default>
          <RepoTree @current-branch="changeCurrentBranch" @branches="setBranches" :isBranchCreating="this.isBranchCreating" @selected-file-change="setPath" :workspace="this.workspace" :branches="this.branches" :currentBranch="this.currentBranch" @update-active-file-content="updateActiveFileContent" @deleted-file="resetNode" @branch-change="changeCurrentBranch"  />
        </template>
        <template #fallback>
          <div class="fallback-repo">
            <font-awesome-icon icon="spinner" class="faa-spin animated" />
          </div>
        </template>
      </Suspense>
      <Suspense v-if="this.showGit">
        <template #default>
          <GitCommands @close-file-opened="closeOpenedFile" :fileOpened="this.fileName" :currentBranch="this.currentBranch" :workspace="this.workspace" :isBranchCreating="this.isBranchCreating" @update-file-content="updateFileContent" @branch-creating="setIsBranchCreating" @branch-created="resetIsBranchCreating"></GitCommands>
        </template>
        <template #fallback>
          <div class="fallback-repo">
            <font-awesome-icon icon="spinner" class="faa-spin animated" />
          </div>
        </template>
      </Suspense>
    </div>

      <!-- <Editor :content="fileContent"/> -->
      <MonacoEditor2 class="editor"
        :value="fileContent"
        :language="this.language"
        :pathName="pathName"
        :fileName="fileName"
        @save-updated-content="autoSaveFileContent"
        @dbt-results="setDbtResults"
        @change="setFileContent"
      />
    <div class="output">
      <button class="result-menu-item" :class="{ 'result-menu-selected': showSqlResults }" @click="setShowSqlResults">Results</button>
      <button class="result-menu-item" :class="{ 'result-menu-selected': showCompileResults }" @click="setShowCompileResults">Compiled SQL</button>
      <button class="result-menu-item" :class="{ 'result-menu-selected': showDbtLogs }" @click="setShowDbtLogs">Dbt Logs</button>
      <div class="sql-results" v-if="showSqlResults" v-html="sqlResult"></div>
      <div class="compiled-sql" v-if="showCompileResults">{{compileResult}}</div>
      <div class="dbt-logs" v-if="showDbtLogs">{{dbtLogs}}</div>
    </div>
  </div>
</template>

<style>

.result-menu-item {
  background-color: white;
  border: none;
  color: gray;
  display: inline;
  top: 5%;
  margin-left: 5px;
}

.result-menu-item:hover {
  cursor: pointer;
  color: black;
}

.compiled-sql {
  white-space: pre-wrap;
  overflow: auto;
  width: 100%;
  height: 80%
}

.dbt-logs {
  top: 10%;
  white-space: pre-wrap;
  overflow: auto;
  height: 80%;
}

.result-menu-selected {
  background-color: blue;
  color: white;
  padding: 5px;

}

.result-menu-selected:hover {
  color: white;
}

.fallback-repo {
  opacity: revert;
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

.commit-button {
  border: 1px solid black;
  border-radius: 8px;
  display: block;
  padding: 4px;
}

.commit-button:hover {
  color: white;
  background-color: black;
  cursor: pointer;

}

.active {
  display: none;
}

.menu-selected {
  border-left: 2px solid white;
}

.menu-highlighted {
  color: white;
  padding-top: 15px;
}

.sql-results {
  top: 10%;
  overflow: auto;
}

.left-menu {
  background: #000000;
  opacity: 90%;
  color: white;
  font-size: 9px;
  font-family: "Arial Narrow";
  cursor: pointer;
}

.left-menu > div {
  text-align: center;
  height: 6%;
  margin-bottom: 10px;
}

.left-menu > div:hover > .menu-item {
  color: white;
}

.menu-item {
  color: gray;
  padding-top: 15px;
  display: inline;
}


.container {
  display: grid;
  width: 100%;
  height: 100%;
  grid-template-areas:
      "left-menu repo-tree editor"
      "left-menu repo-tree output";
  grid-template-columns: 3% 25% 72%;
  grid-template-rows: 550px 250px;
  grid-gap: 0 0;
}

.left-menu {
  grid-area: left-menu;
}

.repo-tree {
  background-color: #d3d3d3;
  grid-area: repo-tree;
  overflow: auto;
}

.editor {
  border: none;
  grid-area: editor;
}

.output {
  grid-area: output;
  border-top: 1px solid lightgrey;
  margin-top: 10px;
}

table, th, td {
  border: 0.5px solid gray;
}

th, td {
  padding: 5px;
  text-align: left;
}

th {
  font-weight: bold;
}

table {
  width: 100%;
  text-align: left;
  overflow: auto;
}

.output > .menu-item:hover {
  border-bottom: 1px black solid;
  cursor: pointer;
}

</style>


<script lang="ts">
import RepoTree from "../components/RepoTree.vue";

import MonacoEditor2 from "../components/MonacoEditor2.vue";
import GitCommands from "../components/GitCommands.vue";
import useApi, {getFile} from "../composables/useApi";

export default({
  name: "dbs-live",
  components: { RepoTree, MonacoEditor2, GitCommands },
  data() {
    return {
      fileContent: "",
      pathName: "",
      gitLogs: "",
      language: "",
      currentBranch: "",
      branches: [],
      compileResult: "",
      sqlResult: "",
      showGit: false,
      showExplorer: true,
      showSqlResults: true,
      showCompileResults: false,
      showDbtLogs: false,
      fileName: "Please select a file.",
      repoTreeVersion: 1,
      node: {"type": "directory"},
      workspace: "pieterjandemuinck",
      dbtLogs: '',
      isBranchCreating: false
    };
  },
  methods: {

    setBranches(branches) {
      this.branches = branches
    },

    resetIsBranchCreating() {
      this.isBranchCreating = false
      this.$forceUpdate()
    },

    setIsBranchCreating() {
      this.isBranchCreating = !this.isBranchCreating
      this.$forceUpdate()
    },

    setPath(path) {
      console.log(path)
      this.pathName = path
      this.fileName = path.split('/').slice(-1)[0]
    },

    closeOpenedFile() {
      console.log('reset files')
      this.pathName = ''
      this.fileName = ''
      this.fileContent = ''
    },

    autoSaveOnInterval: function() {
      setInterval(()=>{
        this.autoSaveFileContent()
      }, 30000);
    },

    setShowGit() {
      this.showExplorer = false
      this.showGit = true
      this.autoSaveFileContent()
    },

    setExplorer(){
      this.showExplorer = true
      this.showGit = false
      this.autoSaveFileContent()
    },

    setShowCompileResults() {
      this.showCompileResults = true
      this.showSqlResults = false
      this.showDbtLogs = false
    },

    setShowSqlResults(){
      this.showCompileResults = false
      this.showSqlResults = true
      this.showDbtLogs = false
    },

    setShowDbtLogs(){
      this.showCompileResults = false
      this.showSqlResults = false
      this.showDbtLogs = true
    },

    refreshRepoTree(){
      console.log("refreshing")
      this.repoTreeVersion += 1;
    },

    setFileContent(content: String) {
      this.fileContent = content
    },

    async updateActiveFileContent(node) {
      await this.autoSaveFileContent(node);
      if(node.type === 'file')  {
        this.fileName = node.path
        this.fileContent = await getFile(this.fileName)
            .then((response) => response.data)
            .catch((err) => console.log(err));

        this.language = this.fileName.split('.').slice(-1)[0];
      }
      this.node = node
      this.pathName = node.path
    },

    async updateFileContent(fileName) {
      if(this.fileName.split('/').slice(-1)[0] === fileName) {
        this.fileContent = await getFile(this.fileName)
            .then((response) => response.data)
            .catch((err) => console.log(err));
      }
    },

    async autoSaveFileContent(node) {
      if (this.fileContent != "" && this.node.type === 'file') {
        console.log("Autosaving");
        await useApi.createFile(this.pathName, this.fileContent)
      }
    },

    async resetNode(node) {
      if(this.node.path === node.path) {
        this.fileName = ''
        this.fileContent = ''
      }
    },

    setDbtResults(result) {
      this.sqlResult =  result.queryResult
      this.compileResult = result.compiledSql
      this.dbtLogs = result.dbtOutput
      this.showDbtLogs = true
      this.showSqlResults = false
      this.showCompileResults = false
    },

    changeCurrentBranch(branch) {
      this.currentBranch = branch
      this.$forceUpdate()
    }

  }
});
</script>

