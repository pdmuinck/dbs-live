<template>
  <div class="monaco-editor-vue3" :style="style">
    <label>{{ fileName.split('/').slice(-1)[0] }}</label>
    <button :disabled="dbtRunning" @click="runDbtModel" :class="{'disable-input': dbtRunning,
    'dbt-run-button': !dbtRunning}">Run</button>
    <button :disabled="dbtRunning" @click="compileDbtModel" :class="{'disable-input': dbtRunning,
    'dbt-run-button': !dbtRunning}">Test</button>
    <button :disabled="dbtRunning" @click="runSeeds" :class="{'disable-input': dbtRunning,
    'dbt-run-button': !dbtRunning}">Seeds</button>
    <font-awesome-icon icon="spinner" class="faa-spin animated" v-if="dbtRunning" />

  </div>
</template>

<script>
import { defineComponent, computed, toRefs, ref } from 'vue'
import * as monaco from 'monaco-editor'
import {dbtOperation} from "../composables/useApi";
export default defineComponent({
  name: "MonacoEditor",
  props: {
    diffEditor: { type: Boolean, default: false },
    width: {type: [String, Number], default: '100%'},
    height: {type: [String, Number], default: '90%'},
    original: String, 
    value: String,
    language: {type: String, default: 'yaml'},
    theme: {type: String, default: 'vs'},
    options: {type: Object, default() {return {};}},
    fileName: {type: String, default: 'new file'},
    pathName: { type: String, default: false }
  },
  emits: [
    'editorWillMount',
    'editorDidMount',
    'change',
    'dbt-results',
    'save-updated-content'
  ],
  setup(props){
    const { width, height } = toRefs(props)
    const style = computed(()=>{
      const fixedWidth = width.value.toString().includes('%') ? width.value : `${width.value}px`
      const fixedHeight = height.value.toString().includes('%')? height.value : `${height.value}px`
      return {
        width: fixedWidth,
        height: fixedHeight,
        'text-align': 'left'
      }
    })
    return {
      style, dbtRunning: ref(false)
    }
  },
  mounted() {
    this.initMonaco()
  },
  beforeDestroy() {
    this.editor && this.editor.dispose();
  },
  methods: {
    initMonaco(){
      this.$emit('editorWillMount', this.monaco)
      const { value, language, theme, options } = this;
      this.editor = monaco.editor[this.diffEditor ? 'createDiffEditor' : 'create'](this.$el, {
        value: value,
        language: language,
        theme: theme,
        ...options
      });

      this.diffEditor && this._setModel(this.value, this.original);
      // @event `change`
      const editor = this._getEditor()
      editor.onDidChangeModelContent(event => {
        const value = editor.getValue()
        if (this.value !== value) {
          this.$emit('change', value, event)
        }
      })
      this.$emit('editorDidMount', this.editor)
    },
    _setModel(value, original) {
      const { language } = this;
      const originalModel = monaco.editor.createModel(original, language);
      const modifiedModel = monaco.editor.createModel(value, language);
      this.editor.setModel({
        original: originalModel,
        modified: modifiedModel
      });
    },
    _setValue(value) {
      let editor = this._getEditor();
      if(editor) return editor.setValue(value);
    },
    _getValue() {
      let editor = this._getEditor();
      if(!editor) return '';
      return editor.getValue();
    },
    _getEditor() {
      if(!this.editor) return null;
      return this.diffEditor ? this.editor.modifiedEditor : this.editor;
    },
    _setOriginal(){
      const { original } = this.editor.getModel()
      original.setValue(this.original)
    },
    saveCode(){
    this.$emit('save-updated-content', this._getValue());
    },
    async compileDbtModel() {
      this.dbtRunning = true
      this.saveCode()
      const dbtResults = await dbtOperation(this.fileName, 'compile')
          .then((response) => response.data)
          .catch((err) => console.log(err));
      this.$emit('dbt-results', dbtResults)
      this.dbtRunning = false
    },

    async runDbtModel() {
      this.dbtRunning = true
      this.saveCode()
      const dbtResults = await dbtOperation(this.fileName, 'run')
          .then((response) => response.data)
          .catch((err) => console.log(err));
      this.$emit('dbt-results', dbtResults)
      this.dbtRunning = false
    },

    async runSeeds()  {
      this.dbtRunning = true
      this.saveCode()
      const dbtResults = await dbtOperation(this.fileName, 'seed')
          .then((response) => response.data)
          .catch((err) => console.log(err));
      this.$emit('dbt-results', dbtResults)
      this.dbtRunning = false
    }
  },
  watch: {
    options: {
      deep: true,
      handler(options) {
        this.editor.updateOptions(options);
      }
    },
    value() {
      this.value !== this._getValue() && this._setValue(this.value);
    },
    original() {
      this._setOriginal()
    },
    language() {
      if(!this.editor) return;
      if(this.diffEditor){
        const { original, modified } = this.editor.getModel();
        monaco.editor.setModelLanguage(original, this.language);
        monaco.editor.setModelLanguage(modified, this.language);
      }else
        monaco.editor.setModelLanguage(this.editor.getModel(), this.language);
    },
    theme() {
      monaco.editor.setTheme(this.theme);
    }
  }
});
</script>

<style scoped>

.disable-input {
  display: none;
}

.monaco-editor-vue3 {
  height: 600px;
  width: 100%;
}

.monaco-editor-vue3 > label {
  display: block;
  margin-left: 1%;
}

.dbt-run-button {
  border: none;
  padding: 6px 8px;
  background-color: white;
  color: gray;
  text-align: center;
  margin-left: 1%;
}

.dbt-run-button:hover {
  cursor: pointer;
  color: black;
}
</style>