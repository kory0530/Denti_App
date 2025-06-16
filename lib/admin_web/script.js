import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm';

const supabaseUrl = 'https://prxzgxtfvmlerivasdyn.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InByeHpneHRmdm1sZXJpdmFzZHluIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg5OTc3OTcsImV4cCI6MjA2NDU3Mzc5N30.14W-OUpmD-FND8fJC2C4Zw5fVWTU_DX7WEQtDv8vuGE'
const supabase = createClient(supabaseUrl, supabaseKey);

// --- Elementos del DOM ---
// Login Section
const loginSection = document.getElementById('login-section');
const mainSection = document.getElementById('main-section');
const loginMsg = document.getElementById('loginMsg');
const loginBtn = document.getElementById('loginBtn');
const logoutBtn = document.getElementById('logoutBtn');
const emailInput = document.getElementById('email');
const passwordInput = document.getElementById('password');
const toast = document.getElementById('toast');

// Articles Section (IDs actualizados)
const articleTitleInput = document.getElementById('articleTitleInput'); // CAMBIO
const articleContentInput = document.getElementById('articleContentInput'); // CAMBIO
const publishArticleButton = document.getElementById('publishArticleButton'); // CAMBIO
const updateArticleButton = document.getElementById('updateArticleButton'); // NUEVO
const cancelArticleEditButton = document.getElementById('cancelArticleEditButton'); // NUEVO
const articlesContainer = document.getElementById('articles');
const articlesSection = document.getElementById('articles-section');

// Recommendations Section (IDs actualizados)
const recommendationTitleInput = document.getElementById('recommendationTitleInput'); // CAMBIO
const recommendationContentInput = document.getElementById('recommendationContentInput'); // CAMBIO
const publishRecommendationButton = document.getElementById('publishRecommendationButton'); // CAMBIO
const updateRecommendationButton = document.getElementById('updateRecommendationButton'); // NUEVO
const cancelRecommendationEditButton = document.getElementById('cancelRecommendationEditButton'); // NUEVO
const recommendationsContainer = document.getElementById('recommendations');
const recommendationsSection = document.getElementById('recommendations-section');

// Navigation Buttons
const btnArticles = document.getElementById('btnArticles');
const btnRecommendations = document.getElementById('btnRecommendations');

// --- Variables para el estado de edición ---
let currentEditingArticleId = null;
let currentEditingRecommendationId = null;


// --- Funciones de Utilidad ---

function showToast(message, type = "info") {
    const toast = document.getElementById('toast');
    if (toast) {
        toast.textContent = message;
        toast.className = `toast show ${type}`;
        setTimeout(() => {
            toast.className = "toast hidden";
        }, 3000);
    } else {
        console.warn('Elemento toast no encontrado en el DOM.');
    }
}


// --- Funciones de Mostrar/Ocultar Secciones ---

function showMain() {
    loginSection.classList.add('hidden');
    mainSection.classList.remove('hidden');
    showSection(articlesSection, btnArticles, fetchArticles);
}

function showLogin() {
    loginSection.classList.remove('hidden');
    mainSection.classList.add('hidden');
    if (emailInput) emailInput.value = '';
    if (passwordInput) passwordInput.value = '';
    if (loginMsg) loginMsg.textContent = '';
}

function showSection(sectionToShow, buttonToActivate, renderFunction) {
    articlesSection.classList.add('hidden');
    recommendationsSection.classList.add('hidden');

    btnArticles.classList.remove('active');
    btnRecommendations.classList.remove('active');

    sectionToShow.classList.remove('hidden');

    if (buttonToActivate) {
        buttonToActivate.classList.add('active');
    }

    if (renderFunction && typeof renderFunction === 'function') {
        renderFunction();
    }
}


// --- Lógica de Navegación ---
if (btnArticles) {
    btnArticles.addEventListener('click', () => {
        showSection(articlesSection, btnArticles, fetchArticles);
    });
}

if (btnRecommendations) {
    btnRecommendations.addEventListener('click', () => {
        showSection(recommendationsSection, btnRecommendations, fetchRecommendations);
    });
}


// --- Lógica de Autenticación ---

async function checkSession() {
    const { data: { session } } = await supabase.auth.getSession();
    if (session) {
        showMain();
    } else {
        showLogin();
    }
}

if (loginBtn) {
    loginBtn.addEventListener('click', async () => {
        const email = emailInput.value.trim();
        const password = passwordInput.value.trim();
        if (!email || !password) {
            loginMsg.textContent = 'Completa email y password.';
            showToast('Completa email y password.', 'warning');
            return;
        }
        loginMsg.textContent = 'Iniciando sesión...';
        showToast('Iniciando sesión...', 'info');

        const { data, error } = await supabase.auth.signInWithPassword({ email, password });

        if (error) {
            loginMsg.textContent = 'Error: ' + error.message;
            showToast('Error al iniciar sesión: ' + error.message, 'error');
        } else {
            loginMsg.textContent = '';
            showToast('Inicio de sesión exitoso.', 'success');
            showMain();
        }
    });
}

if (logoutBtn) {
    logoutBtn.addEventListener('click', async () => {
        const { error } = await supabase.auth.signOut();
        if (error) {
            console.error('Error al cerrar sesión:', error.message);
            showToast('Error al cerrar sesión.', 'error');
        } else {
            showLogin();
            showToast('Sesión cerrada correctamente.', 'info');
        }
    });
}


// --- Funciones para Artículos ---

/**
 * Carga y muestra los artículos desde Supabase, limpiando el contenedor previamente.
 * También adjunta los listeners para editar/eliminar.
 */
async function fetchArticles() {
    articlesContainer.innerHTML = '';
    const { data, error } = await supabase.from('articles').select('*').order('created_at', { ascending: false });

    if (error) {
        console.error('Error al obtener artículos:', error.message);
        showToast('Error al cargar los artículos.', 'error');
        return;
    }

    if (data && data.length > 0) {
        data.forEach(article => {
            const articleElement = document.createElement('div');
            articleElement.className = 'article-item';
            articleElement.innerHTML = `
                <h3>${article.title}</h3>
                <p>${article.content}</p>
                <div class="actions">
                    <button class="edit-article-btn" data-id="${article.id}" data-title="${article.title}" data-content="${article.content}"><i class="fas fa-edit"></i> Editar</button>
                    <button class="delete-article-btn" data-id="${article.id}"><i class="fas fa-trash-alt"></i> Eliminar</button>
                </div>
            `;
            articlesContainer.appendChild(articleElement);
        });
        attachArticleActionListeners();
    } else {
        articlesContainer.innerHTML = '<p>No hay artículos publicados.</p>';
    }
}

/**
 * Adjunta listeners a los botones de acción (editar, eliminar) de los artículos.
 */
function attachArticleActionListeners() {
    document.querySelectorAll('.delete-article-btn').forEach(button => {
        button.onclick = async (event) => {
            const articleId = event.currentTarget.dataset.id;
            if (confirm('¿Estás seguro de que quieres eliminar este artículo?')) {
                await deleteArticle(articleId);
            }
        };
    });

    document.querySelectorAll('.edit-article-btn').forEach(button => {
        button.onclick = (event) => {
            const articleId = event.currentTarget.dataset.id;
            const articleTitle = event.currentTarget.dataset.title;
            const articleContent = event.currentTarget.dataset.content;
            editArticle(articleId, articleTitle, articleContent);
        };
    });
}

/**
 * Elimina un artículo por su ID de Supabase y refresca la lista.
 * @param {string} id El ID del artículo a eliminar.
 */
async function deleteArticle(id) {
    const { error } = await supabase.from('articles').delete().eq('id', id);
    if (error) {
        console.error('Error al eliminar artículo:', error.message);
        showToast('Error al eliminar artículo.', 'error');
        return;
    }
    showToast('Artículo eliminado correctamente.', 'success');
    fetchArticles(); // Refresca la lista después de eliminar
}

/**
 * Prepara el formulario de artículo para la edición.
 * @param {string} id El ID del artículo a editar.
 * @param {string} title El título del artículo.
 * @param {string} content El contenido del artículo.
 */
function editArticle(id, title, content) {
    articleTitleInput.value = title;
    articleContentInput.value = content;
    currentEditingArticleId = id; // Guardar el ID del artículo que se está editando

    publishArticleButton.classList.add('hidden'); // Ocultar botón de publicar
    updateArticleButton.classList.remove('hidden'); // Mostrar botón de actualizar
    cancelArticleEditButton.classList.remove('hidden'); // Mostrar botón de cancelar
    showToast('Modifica el artículo y haz clic en "Actualizar Artículo".', 'info');
}

/**
 * Actualiza un artículo existente en Supabase.
 */
async function updateArticle() {
    if (!currentEditingArticleId) {
        showToast('Error: No hay artículo seleccionado para actualizar.', 'error');
        return;
    }

    const title = articleTitleInput.value.trim();
    const content = articleContentInput.value.trim();

    if (!title || !content) {
        showToast('El título y el contenido son obligatorios para actualizar.', 'warning');
        return;
    }

    const { error } = await supabase
        .from('articles')
        .update({ title, content })
        .eq('id', currentEditingArticleId);

    if (error) {
        console.error('Error al actualizar artículo:', error.message);
        showToast('Error al actualizar artículo: ' + error.message, 'error');
        return;
    }

    showToast('Artículo actualizado correctamente.', 'success');
    resetArticleForm(); // Limpiar y restablecer el formulario
    fetchArticles(); // Refrescar la lista de artículos
}

/**
 * Restablece el formulario de artículo a su estado inicial (publicar nuevo).
 */
function resetArticleForm() {
    articleTitleInput.value = '';
    articleContentInput.value = '';
    currentEditingArticleId = null; // Borrar el ID de edición

    publishArticleButton.classList.remove('hidden'); // Mostrar botón de publicar
    updateArticleButton.classList.add('hidden'); // Ocultar botón de actualizar
    cancelArticleEditButton.classList.add('hidden'); // Ocultar botón de cancelar
}

// Event Listeners para los botones de Publicar, Actualizar y Cancelar Artículo
if (publishArticleButton) {
    publishArticleButton.addEventListener('click', async () => {
        const title = articleTitleInput.value.trim();
        const content = articleContentInput.value.trim();
        if (!title || !content) {
            showToast('El título y el contenido son obligatorios.', 'warning');
            return;
        }

        const { data: { user }, error: userError } = await supabase.auth.getUser();
        if (userError || !user) {
            showToast('Debe iniciar sesión para publicar un artículo.', 'error');
            return;
        }

        const { error } = await supabase.from('articles').insert([
            { title, content, user_id: user.id } // Asegúrate de incluir user_id
        ]);
        if (error) {
            showToast('Error al publicar artículo: ' + error.message, 'error');
            return;
        }

        showToast('Artículo publicado correctamente.', 'success');
        resetArticleForm();
        fetchArticles();
    });
}

if (updateArticleButton) {
    updateArticleButton.addEventListener('click', updateArticle);
}

if (cancelArticleEditButton) {
    cancelArticleEditButton.addEventListener('click', () => {
        resetArticleForm();
        showToast('Edición de artículo cancelada.', 'info');
    });
}


// --- Funciones para Recomendaciones ---

/**
 * Carga y muestra las recomendaciones desde Supabase, limpiando el contenedor previamente.
 * También adjunta los listeners para editar/eliminar.
 */
async function fetchRecommendations() {
    recommendationsContainer.innerHTML = '';
    const { data, error } = await supabase.from('recommendations').select('*').order('created_at', { ascending: false });

    if (error) {
        console.error('Error al obtener recomendaciones:', error.message);
        showToast('Error al cargar las recomendaciones.', 'error');
        return;
    }

    if (data && data.length > 0) {
        data.forEach(rec => {
            const recommendationElement = document.createElement('div');
            recommendationElement.className = 'recommendation-item';
            recommendationElement.innerHTML = `
                <h3>${rec.title}</h3>
                <p>${rec.content}</p>
                <div class="actions">
                    <button class="edit-rec-btn" data-id="${rec.id}" data-title="${rec.title}" data-content="${rec.content}"><i class="fas fa-edit"></i> Editar</button>
                    <button class="delete-rec-btn" data-id="${rec.id}"><i class="fas fa-trash-alt"></i> Eliminar</button>
                </div>
            `;
            recommendationsContainer.appendChild(recommendationElement);
        });
        attachRecommendationActionListeners();
    } else {
        recommendationsContainer.innerHTML = '<p>No hay recomendaciones publicadas.</p>';
    }
}

/**
 * Adjunta listeners a los botones de acción (editar, eliminar) de las recomendaciones.
 */
function attachRecommendationActionListeners() {
    document.querySelectorAll('.delete-rec-btn').forEach(button => {
        button.onclick = async (event) => {
            const recId = event.currentTarget.dataset.id;
            if (confirm('¿Estás seguro de que quieres eliminar esta recomendación?')) {
                await deleteRecommendation(recId);
            }
        };
    });

    document.querySelectorAll('.edit-rec-btn').forEach(button => {
        button.onclick = (event) => {
            const recId = event.currentTarget.dataset.id;
            const recTitle = event.currentTarget.dataset.title;
            const recContent = event.currentTarget.dataset.content;
            editRecommendation(recId, recTitle, recContent);
        };
    });
}

/**
 * Elimina una recomendación por su ID de Supabase y refresca la lista.
 * @param {string} id El ID de la recomendación a eliminar.
 */
async function deleteRecommendation(id) {
    const { error } = await supabase.from('recommendations').delete().eq('id', id);
    if (error) {
        console.error('Error al eliminar recomendación:', error.message);
        showToast('Error al eliminar recomendación.', 'error');
        return;
    }
    showToast('Recomendación eliminada correctamente.', 'success');
    fetchRecommendations(); // Refresca la lista después de eliminar
}

/**
 * Prepara el formulario de recomendación para la edición.
 * @param {string} id El ID de la recomendación a editar.
 * @param {string} title El título de la recomendación.
 * @param {string} content El contenido de la recomendación.
 */
function editRecommendation(id, title, content) {
    recommendationTitleInput.value = title;
    recommendationContentInput.value = content;
    currentEditingRecommendationId = id; // Guardar el ID de la recomendación que se está editando

    publishRecommendationButton.classList.add('hidden'); // Ocultar botón de publicar
    updateRecommendationButton.classList.remove('hidden'); // Mostrar botón de actualizar
    cancelRecommendationEditButton.classList.remove('hidden'); // Mostrar botón de cancelar
    showToast('Modifica la recomendación y haz clic en "Actualizar Recomendación".', 'info');
}

/**
 * Actualiza una recomendación existente en Supabase.
 */
async function updateRecommendation() {
    if (!currentEditingRecommendationId) {
        showToast('Error: No hay recomendación seleccionada para actualizar.', 'error');
        return;
    }

    const title = recommendationTitleInput.value.trim();
    const content = recommendationContentInput.value.trim();

    if (!title || !content) {
        showToast('El título y el contenido son obligatorios para actualizar.', 'warning');
        return;
    }

    const { error } = await supabase
        .from('recommendations')
        .update({ title, content })
        .eq('id', currentEditingRecommendationId);

    if (error) {
        console.error('Error al actualizar recomendación:', error.message);
        showToast('Error al actualizar recomendación: ' + error.message, 'error');
        return;
    }

    showToast('Recomendación actualizada correctamente.', 'success');
    resetRecommendationForm(); // Limpiar y restablecer el formulario
    fetchRecommendations(); // Refrescar la lista de recomendaciones
}

/**
 * Restablece el formulario de recomendación a su estado inicial (publicar nuevo).
 */
function resetRecommendationForm() {
    recommendationTitleInput.value = '';
    recommendationContentInput.value = '';
    currentEditingRecommendationId = null; // Borrar el ID de edición

    publishRecommendationButton.classList.remove('hidden'); // Mostrar botón de publicar
    updateRecommendationButton.classList.add('hidden'); // Ocultar botón de actualizar
    cancelRecommendationEditButton.classList.add('hidden'); // Ocultar botón de cancelar
}

// Event Listeners para los botones de Publicar, Actualizar y Cancelar Recomendación
if (publishRecommendationButton) {
    publishRecommendationButton.addEventListener('click', async () => {
        const title = recommendationTitleInput.value.trim();
        const content = recommendationContentInput.value.trim();
        if (!title || !content) {
            showToast('Completa todos los campos para la recomendación.', 'warning');
            return;
        }

        const { data: { user }, error: userError } = await supabase.auth.getUser();
        if (userError || !user) {
            showToast('Debe iniciar sesión para agregar una recomendación.', 'error');
            return;
        }

        const { error } = await supabase.from('recommendations').insert([
            { title, content, user_id: user.id } // Asegúrate de incluir user_id
        ]);
        if (error) {
            showToast('Error al agregar recomendación: ' + error.message, 'error');
            return;
        }

        showToast('Recomendación agregada exitosamente.', 'success');
        resetRecommendationForm();
        fetchRecommendations();
    });
}

if (updateRecommendationButton) {
    updateRecommendationButton.addEventListener('click', updateRecommendation);
}

if (cancelRecommendationEditButton) {
    cancelRecommendationEditButton.addEventListener('click', () => {
        resetRecommendationForm();
        showToast('Edición de recomendación cancelada.', 'info');
    });
}


// --- Inicio de la Aplicación ---
checkSession(); 