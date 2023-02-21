import { createApp } from 'vue'
import { createPinia } from 'pinia'

import App from './App.vue'
import router from './router'
import './index.css'
import 'font-awesome-animation/css/font-awesome-animation.min.css'

import { library } from '@fortawesome/fontawesome-svg-core'

/* import specific icons */
import {faFileEdit, faCodeBranch, faFileCirclePlus, faGreaterThan, faSpinner, faAngleRight, faAngleDown, faFolderPlus, faFileCircleXmark, faRotateLeft }
from '@fortawesome/free-solid-svg-icons'


import { faFile, faFolder, faFileLines } from '@fortawesome/free-regular-svg-icons'

/* import font awesome icon component */
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

/* add icons to the library */
library.add(faFile, faFolder, faCodeBranch, faFileCirclePlus, faGreaterThan, faSpinner, faAngleRight, faAngleDown, faFolderPlus, faFileCircleXmark, faRotateLeft
, faFileEdit)

/* add font awesome icon component */




const app = createApp(App)

app.component('font-awesome-icon', FontAwesomeIcon)

app.use(createPinia())
app.use(router)

app.mount('#app')
