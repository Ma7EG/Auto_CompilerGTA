const translations = {
    en: {
        'main-title': '🛠️ Automatic Compilation Tool',
        'minimize-tooltip': 'Minimize',
        'close-tooltip': 'Close',
        'scripts-list-title': '📋 Scripts List',
        'refresh-btn': '🔄 Refresh List',
        'search-placeholder': 'Search scripts...',
        'script-name-header': 'Script Name',
        'protection-header': 'cache=false',
        'status-header': 'Status',
        'files-title': '📁 Script Files',
        'file-header': 'File',
        'type-header': 'Type',
        'no-selection': 'Select a script from the list',
        'compilation-options-title': '⚙️ Compilation Options',
        'compile-client': 'Compile client-files only',
        'compile-server': 'Compile server-files only',
        'enable-protection': 'Activate cache=false protection',
        'protection-warning': 'Warning: the script will be loaded into RAM memory making the download take longer',
        'compile-selected-btn': 'Compile Selected',
        'compile-all-btn': 'Compile All Server',
        'restart-after-compile': 'Restart script after compilation',
        'copyright': '© 2025 • Creator: BranD • Company: Trident Sky Network',
        'status-compiled': 'Compiled',
        'status-uncompiled': 'Uncompiled',
        'type-client': 'Client',
        'type-server': 'Server',
        'confirmation-title': '⚠️ Confirmation',
        'compile-selected-confirm': 'Are you sure you want to compile the following scripts?\n\n{scripts}\n\nOptions:\n- Client-files: {client}\n- Server-files: {server}\n- Protection: {protection}',
        'compile-all-confirm': 'Are you sure you want to compile ALL server scripts?\n\nThis action will compile according to the selected options.',
        'btn-accept': 'Accept',
        'btn-cancel': 'Cancel',
        'alert-no-scripts': 'Please select at least one script.',
        'alert-no-options': 'Please select at least one compilation option.',
        'yes': 'Yes',
        'no': 'No'
    },
    es: {
        'main-title': '🛠️ Herramienta de Compilación Automática',
        'minimize-tooltip': 'Minimizar',
        'close-tooltip': 'Cerrar',
        'scripts-list-title': '📋 Lista de Scripts',
        'refresh-btn': '🔄 Refrescar Lista',
        'search-placeholder': 'Buscar scripts...',
        'script-name-header': 'Nombre del Script',
        'protection-header': 'cache=false',
        'status-header': 'Estado',
        'files-title': '📁 Archivos del Script',
        'file-header': 'Archivo',
        'type-header': 'Tipo',
        'no-selection': 'Selecciona un script de la lista',
        'compilation-options-title': '⚙️ Opciones de Compilación',
        'compile-client': 'Compilar solo client-files',
        'compile-server': 'Compilar solo server-files',
        'enable-protection': 'Activar la protección cache=false',
        'protection-warning': 'Advertencia: el script se cargará en la memoria RAM haciendo que tarde más la descarga',
        'compile-selected-btn': 'Compilar Seleccionados',
        'compile-all-btn': 'Compilar Todo el Servidor',
        'restart-after-compile': 'Reiniciar script al terminar de compilar',
        'copyright': '© 2025 • Creador: BranD • Compañía: Trident Sky Network',
        'status-compiled': 'Compilado',
        'status-uncompiled': 'Sin Compilar',
        'type-client': 'Client',
        'type-server': 'Server',
        'confirmation-title': '⚠️ Confirmación',
        'compile-selected-confirm': '¿Estás seguro de compilar los siguientes scripts?\n\n{scripts}\n\nOpciones:\n- Client-files: {client}\n- Server-files: {server}\n- Protección: {protection}',
        'compile-all-confirm': '¿Estás seguro de compilar TODOS los scripts del servidor?\n\nEsta acción compilará según las opciones seleccionadas.',
        'btn-accept': 'Aceptar',
        'btn-cancel': 'Cancelar',
        'alert-no-scripts': 'Por favor selecciona al menos un script.',
        'alert-no-options': 'Por favor selecciona al menos una opción de compilación.',
        'yes': 'Sí',
        'no': 'No'
    },
    pt: {
        'main-title': '🛠️ Ferramenta de Compilação Automática',
        'minimize-tooltip': 'Minimizar',
        'close-tooltip': 'Fechar',
        'scripts-list-title': '📋 Lista de Scripts',
        'refresh-btn': '🔄 Atualizar Lista',
        'search-placeholder': 'Pesquisar scripts...',
        'script-name-header': 'Nome do Script',
        'protection-header': 'cache=false',
        'status-header': 'Status',
        'files-title': '📁 Arquivos do Script',
        'file-header': 'Arquivo',
        'type-header': 'Tipo',
        'no-selection': 'Selecione um script da lista',
        'compilation-options-title': '⚙️ Opções de Compilação',
        'compile-client': 'Compilar apenas client-files',
        'compile-server': 'Compilar apenas server-files',
        'enable-protection': 'Ativar proteção cache=false',
        'protection-warning': 'Aviso: o script será carregado na memória RAM fazendo o download demorar mais',
        'compile-selected-btn': 'Compilar Selecionados',
        'compile-all-btn': 'Compilar Todo o Servidor',
        'restart-after-compile': 'Reiniciar script após compilação',
        'copyright': '© 2025 • Criador: BranD • Empresa: Trident Sky Network',
        'status-compiled': 'Compilado',
        'status-uncompiled': 'Não Compilado',
        'type-client': 'Client',
        'type-server': 'Server',
        'confirmation-title': '⚠️ Confirmação',
        'compile-selected-confirm': 'Tem certeza de que quer compilar os seguintes scripts?\n\n{scripts}\n\nOpções:\n- Client-files: {client}\n- Server-files: {server}\n- Proteção: {protection}',
        'compile-all-confirm': 'Tem certeza de que quer compilar TODOS os scripts do servidor?\n\nEsta ação compilará de acordo com as opções selecionadas.',
        'btn-accept': 'Aceitar',
        'btn-cancel': 'Cancelar',
        'alert-no-scripts': 'Por favor, selecione pelo menos um script.',
        'alert-no-options': 'Por favor, selecione pelo menos uma opção de compilação.',
        'yes': 'Sim',
        'no': 'Não'
    }
};

let currentLanguage = 'en';
let scriptsData = [];
let filteredScripts = [];
let selectedScripts = [];
let currentScript = null;
let pendingAction = null;

function setLanguage(lang) {
    currentLanguage = lang;
    
    document.querySelectorAll('.lang-btn').forEach(btn => {
        btn.classList.remove('active');
    });
    
    document.querySelectorAll('.lang-btn').forEach(btn => {
        if (btn.textContent === lang.toUpperCase()) {
            btn.classList.add('active');
        }
    });
    
    const elements = document.querySelectorAll('[data-lang]');
    elements.forEach(element => {
        const key = element.getAttribute('data-lang');
        if (translations[lang] && translations[lang][key]) {
            if (element.tagName === 'INPUT' && element.type === 'text') {
                element.placeholder = translations[lang][key];
            } else if (element.hasAttribute('title')) {
                element.title = translations[lang][key];
            } else {
                element.innerHTML = translations[lang][key];
            }
        }
    });
    
    if (currentScript !== null) {
        updateFilesList(scriptsData[currentScript]);
    }
    
    renderScripts();
}

function loadScriptsData(scripts) {
    if (!scripts) {
        scripts = [];
    }
    
    if (typeof scripts === 'string') {
        try {
            scripts = JSON.parse(scripts);
        } catch (e) {
            scripts = [];
        }
    }
    
    if (!Array.isArray(scripts)) {
        scripts = [scripts];
    }
    
    scriptsData = scripts;
    filteredScripts = [...scriptsData];
    selectedScripts = [];
    currentScript = null;
    
    const selectAllCheckbox = document.getElementById('selectAll');
    if (selectAllCheckbox) {
        selectAllCheckbox.checked = false;
    }
    
    renderScripts();
}

function renderScripts() {
    const scriptsContainer = document.getElementById('scriptsGridlist');
    scriptsContainer.innerHTML = '';
    
    if (!filteredScripts || filteredScripts.length === 0) {
        const noData = document.createElement('div');
        noData.className = 'no-selection';
        noData.setAttribute('data-lang', 'no-selection');
        noData.textContent = translations[currentLanguage]['no-selection'];
        scriptsContainer.appendChild(noData);
        return;
    }
    
    filteredScripts.forEach((script, index) => {
        if (!script || !script.name) return;
        
        const originalIndex = scriptsData.indexOf(script);
        const row = createScriptRow(script, originalIndex);
        scriptsContainer.appendChild(row);
    });
}

function createScriptRow(script, index) {
    if (!script || !script.name) return null;
    
    const row = document.createElement('div');
    row.className = 'gridlist-row scripts-row';
    row.setAttribute('data-script-id', index);
    
    const protectionStatus = script.hasProtection ? 'ON' : 'OFF';
    const protectionClass = script.hasProtection ? 'status-on' : 'status-off';
    
    const hasUncompiledClient = script.clientFiles && script.clientFiles.length > 0 && !script.clientCompiled;
    const statusText = hasUncompiledClient ? translations[currentLanguage]['status-uncompiled'] : translations[currentLanguage]['status-compiled'];
    const statusClass = hasUncompiledClient ? 'status-uncompiled' : 'status-on';
    
    const isSelected = selectedScripts.includes(index);
    
    row.innerHTML = `
        <div class="gridlist-cell">
            <input type="checkbox" class="checkbox-script" ${isSelected ? 'checked' : ''} onchange="toggleScriptSelection(${index})">
        </div>
        <div class="gridlist-cell" onclick="selectScript(${index})">${script.name || 'Unknown'}</div>
        <div class="gridlist-cell">
            <span class="${protectionClass}">${protectionStatus}</span>
        </div>
        <div class="gridlist-cell">
            <span class="${statusClass}">${statusText}</span>
        </div>
    `;
    
    return row;
}

function filterScripts() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    filteredScripts = scriptsData.filter(script => 
        script.name.toLowerCase().includes(searchTerm)
    );
    renderScripts();
}

function toggleSelectAll() {
    const selectAllCheckbox = document.getElementById('selectAll');
    
    if (selectAllCheckbox.checked) {
        selectedScripts = filteredScripts.map((script, index) => scriptsData.indexOf(script));
    } else {
        selectedScripts = [];
    }
    
    renderScripts();
}

function toggleScriptSelection(index) {
    if (selectedScripts.includes(index)) {
        selectedScripts = selectedScripts.filter(id => id !== index);
    } else {
        selectedScripts.push(index);
    }
    
    const selectAllCheckbox = document.getElementById('selectAll');
    selectAllCheckbox.checked = selectedScripts.length === filteredScripts.length;
}

function selectScript(index) {
    const rows = document.querySelectorAll('.scripts-row');
    rows.forEach(row => row.classList.remove('selected'));
    
    const selectedRow = document.querySelector(`[data-script-id="${index}"]`);
    if (selectedRow) {
        selectedRow.classList.add('selected');
    }
    
    currentScript = index;
    updateFilesList(scriptsData[index]);
    updateControls(scriptsData[index]);
}

function updateFilesList(script) {
    const filesContainer = document.getElementById('filesGridlist');
    filesContainer.innerHTML = '';
    
    const allFiles = [
        ...(script.clientFiles || []).map(file => ({ name: file, type: 'client' })),
        ...(script.serverFiles || []).map(file => ({ name: file, type: 'server' }))
    ];
    
    if (allFiles.length === 0) {
        const noFiles = document.createElement('div');
        noFiles.className = 'no-selection';
        noFiles.textContent = 'No files found';
        filesContainer.appendChild(noFiles);
        return;
    }
    
    allFiles.forEach(file => {
        const row = document.createElement('div');
        row.className = 'gridlist-row files-row';
        
        const typeClass = file.type === 'client' ? 'type-client' : 'type-server';
        const typeText = file.type === 'client' ? translations[currentLanguage]['type-client'] : translations[currentLanguage]['type-server'];
        
        row.innerHTML = `
            <div class="gridlist-cell">${file.name}</div>
            <div class="gridlist-cell">
                <span class="${typeClass}">${typeText}</span>
            </div>
        `;
        
        filesContainer.appendChild(row);
    });
}

function updateControls(script) {
    document.getElementById('compileClient').checked = true;
    document.getElementById('compileServer').checked = false;
    document.getElementById('enableProtection').checked = false;
}

function showConfirmation(action) {
    const modal = document.getElementById('confirmationModal');
    const messageEl = document.getElementById('modalMessage');
    const titleEl = document.querySelector('.modal-title');
    
    titleEl.textContent = translations[currentLanguage]['confirmation-title'];
    
    let message = '';
    
    if (action === 'compileSelected') {
        if (selectedScripts.length === 0) {
            return;
        }
        
        const compileClient = document.getElementById('compileClient').checked;
        const compileServer = document.getElementById('compileServer').checked;
        
        if (!compileClient && !compileServer) {
            return;
        }
        
        const selectedNames = selectedScripts.map(index => scriptsData[index].name).join(', ');
        const clientText = compileClient ? translations[currentLanguage]['yes'] : translations[currentLanguage]['no'];
        const serverText = compileServer ? translations[currentLanguage]['yes'] : translations[currentLanguage]['no'];
        const protectionText = document.getElementById('enableProtection').checked ? translations[currentLanguage]['yes'] : translations[currentLanguage]['no'];
        
        message = translations[currentLanguage]['compile-selected-confirm']
            .replace('{scripts}', selectedNames)
            .replace('{client}', clientText)
            .replace('{server}', serverText)
            .replace('{protection}', protectionText);
    } else if (action === 'compileAll') {
        const compileClient = document.getElementById('compileClient').checked;
        const compileServer = document.getElementById('compileServer').checked;
        
        if (!compileClient && !compileServer) {
            return;
        }
        
        message = translations[currentLanguage]['compile-all-confirm'];
    }
    
    messageEl.textContent = message;
    
    document.querySelector('.btn-confirm').textContent = translations[currentLanguage]['btn-accept'];
    document.querySelector('.btn-cancel').textContent = translations[currentLanguage]['btn-cancel'];
    
    pendingAction = action;
    modal.style.display = 'flex';
}

function confirmAction() {
    if (pendingAction === 'compileSelected') {
        compileSelected();
    } else if (pendingAction === 'compileAll') {
        compileAllServer();
    }
    
    closeModal();
}

function closeModal() {
    document.getElementById('confirmationModal').style.display = 'none';
    pendingAction = null;
}

function compileSelected() {
    const compileClient = document.getElementById('compileClient').checked;
    const compileServer = document.getElementById('compileServer').checked;
    const enableProtection = document.getElementById('enableProtection').checked;
    const restartAfterCompile = document.getElementById('restartAfterCompile').checked;
    
    const compilationTasks = selectedScripts.map(index => ({
        resourceName: scriptsData[index].name,
        compileClient: compileClient,
        compileServer: compileServer,
        enableProtection: enableProtection,
        restartAfterCompile: restartAfterCompile
    }));
    
    mta.triggerEvent("startCompilation", JSON.stringify(compilationTasks));
}

function compileAllServer() {
    const compileClient = document.getElementById('compileClient').checked;
    const compileServer = document.getElementById('compileServer').checked;
    const enableProtection = document.getElementById('enableProtection').checked;
    const restartAfterCompile = document.getElementById('restartAfterCompile').checked;
    
    const compilationTasks = [{
        resourceName: "ALL_SERVER_SCRIPTS",
        compileClient: compileClient,
        compileServer: compileServer,
        enableProtection: enableProtection,
        restartAfterCompile: restartAfterCompile
    }];
    
    mta.triggerEvent("startCompilation", JSON.stringify(compilationTasks));
}

function closePanel() {
    mta.triggerEvent("closePanel");
}

function minimizePanel() {
    mta.triggerEvent("minimizePanel");
}

function refreshScriptsList() {
    mta.triggerEvent("refreshScriptsList");
    
    selectedScripts = [];
    currentScript = null;
    document.getElementById('selectAll').checked = false;
    document.getElementById('filesGridlist').innerHTML = `<div class="no-selection" data-lang="no-selection">${translations[currentLanguage]['no-selection']}</div>`;
    document.getElementById('searchInput').value = '';
}

function updateCompilationProgress(data) {
    if (data.type === 'complete') {
        mta.triggerEvent("refreshScriptsList");
    }
}

window.onload = function() {
    setTimeout(() => {
        if (typeof mta !== 'undefined' && mta.triggerEvent) {
            mta.triggerEvent("requestScriptsList");
        }
    }, 1000);
};