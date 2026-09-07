const state = { items: [], stock: {}, category: 'all', search: '', currencySymbol: '$' };
const app = document.getElementById('app');
const itemGrid = document.getElementById('items');
const empty = document.getElementById('empty');
const notice = document.getElementById('notice');

const iconFor = (item) => {
    const value = (item.icon || '').toLowerCase();
    if (value.includes('key')) return '⌕';
    if (value.includes('bag')) return '▱';
    if (value.includes('screw')) return '✣';
    if (value.includes('gun') || value.includes('weapon')) return '◈';
    return '✦';
};

const resourceName = typeof GetParentResourceName === 'function' ? GetParentResourceName() : 'CCD_BlackMarket';
function post(name, data = {}) {
    fetch(`https://${resourceName}/${name}`, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(data) }).catch(() => {});
}

function setNotice(message, isError = false) {
    notice.textContent = message || '';
    notice.className = `notice${isError ? ' error' : ''}`;
    if (message) setTimeout(() => { if (notice.textContent === message) notice.textContent = ''; }, 3500);
}

function categories() {
    const values = [...new Set(state.items.map((item) => item.category || 'Other'))].sort();
    const list = document.getElementById('category-list');
    list.innerHTML = values.map((category) => `<button class="category" data-category="${category}">${category} <span>${state.items.filter((item) => (item.category || 'Other') === category).length}</span></button>`).join('');
    document.querySelectorAll('.category').forEach((button) => button.onclick = () => selectCategory(button.dataset.category));
    document.getElementById('all-count').textContent = state.items.length;
}

function render() {
    const query = state.search.toLowerCase();
    const visible = state.items.map((item, index) => ({ item, index })).filter(({ item }) => {
        const matchesCategory = state.category === 'all' || (item.category || 'Other') === state.category;
        const matchesSearch = !query || `${item.label} ${item.description} ${item.item}`.toLowerCase().includes(query);
        return matchesCategory && matchesSearch;
    });
    itemGrid.innerHTML = visible.map(({ item, index }) => {
        const stockValue = Array.isArray(state.stock)
            ? state.stock[index]
            : state.stock[index + 1] ?? state.stock[String(index + 1)];
        const available = Number(stockValue ?? item.stock ?? 0);
        const purchaseAmount = Number(item.amount || 1);
        const out = available < purchaseAmount;
        const stockClass = out ? 'empty' : available <= purchaseAmount * 2 ? 'low' : '';
        const visual = item.image
            ? `<img src="${item.image}" alt=""><span class="icon-fallback">${iconFor(item)}</span>`
            : `<span class="icon-fallback">${iconFor(item)}</span>`;
        return `<article class="card${out ? ' out' : ''}">
            <div class="card-icon">${visual}</div>
            <div class="card-category">${item.category || 'Other'}</div>
            <h2>${item.label}</h2><p>${item.description || 'Unlisted supply.'}</p>
            <div class="card-bottom"><div class="price">${state.currencySymbol}${item.price}<small> / ${purchaseAmount}</small></div><div class="stock ${stockClass}">${out ? 'OUT OF STOCK' : `${available} IN STOCK`}</div></div>
            <button class="buy" data-index="${index + 1}" ${out ? 'disabled' : ''}>${out ? 'Unavailable' : 'Acquire supply'}</button>
        </article>`;
    }).join('');
    empty.hidden = visible.length !== 0;
    itemGrid.querySelectorAll('.buy').forEach((button) => button.addEventListener('click', () => { button.disabled = true; post('buy', { index: Number(button.dataset.index) }); }));
}

function selectCategory(category) {
    state.category = category;
    document.querySelectorAll('.category').forEach((button) => button.classList.toggle('active', button.dataset.category === category));
    render();
}

window.addEventListener('message', ({ data }) => {
    if (data.action === 'open') {
        app.style.display = 'flex';
        app.classList.add('visible');
        app.setAttribute('aria-hidden', 'false');
        const incomingItems = data.items || [];
        state.items = Array.isArray(incomingItems) ? incomingItems : Object.keys(incomingItems).sort((a, b) => Number(a) - Number(b)).map((key) => incomingItems[key]);
        state.currencySymbol = data.currencySymbol || '$'; state.category = 'all'; state.search = '';
        document.getElementById('market-title').textContent = data.title || 'BLACK MARKET';
        document.getElementById('market-subtitle').textContent = data.subtitle || 'Private supply channel';
        document.getElementById('search').value = ''; categories(); selectCategory('all'); app.classList.add('visible'); app.setAttribute('aria-hidden', 'false');
    } else if (data.action === 'stock') { state.stock = data.stock || {}; render();
    } else if (data.action === 'purchaseResult') { state.stock = data.stock || state.stock; setNotice(data.message, !data.success); render(); }
    else if (data.action === 'close') { app.classList.remove('visible'); app.style.display = 'none'; app.setAttribute('aria-hidden', 'true'); }
});

document.getElementById('search').addEventListener('input', (event) => { state.search = event.target.value; render(); });
document.getElementById('close-button').addEventListener('click', () => { app.classList.remove('visible'); app.style.display = 'none'; app.setAttribute('aria-hidden', 'true'); post('close'); });
document.addEventListener('keydown', (event) => { if (event.key === 'Escape' && app.classList.contains('visible')) { app.classList.remove('visible'); app.style.display = 'none'; app.setAttribute('aria-hidden', 'true'); post('close'); } });
post('ready');
