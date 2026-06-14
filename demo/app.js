const classes = {
  Disease: "#2f7d57",
  Gene: "#3e74a8",
  Protein: "#247b7b",
  Pathway: "#7161a8",
  Metabolite: "#c88322",
  Tissue: "#8a6f3d",
  CellType: "#b75d69",
};

const entityAttributes = {
  Disease: {
    confirmed: ["disease_id", "disease_name", "umls_id"],
    recommended: ["project_id", "mesh_id", "omim_id", "synonyms", "is_progression_stage", "stage_order"],
    planned: ["disease_type", "clinical_stage_definition", "description"],
  },
  Gene: {
    confirmed: ["gene_id", "gene_symbol", "gene_name"],
    recommended: ["project_id", "primary_external_id", "external_ids", "synonyms", "source"],
    planned: ["chromosome_location", "gene_type", "organism"],
  },
  Protein: {
    confirmed: ["protein_id", "protein_symbol", "protein_name", "organism"],
    recommended: ["project_id", "primary_external_id", "external_ids", "synonyms"],
    planned: ["taxonomy_id", "encoded_by_gene_id"],
  },
  Pathway: {
    confirmed: ["pathway_id", "pathway_name", "pathway_category", "pathway_source", "source"],
    recommended: ["project_id", "external_ids", "synonyms"],
    planned: ["pathway_description"],
  },
  Metabolite: {
    confirmed: ["metabolite_id", "metabolite_name", "chemical_formula", "molecular_weight", "source"],
    recommended: ["project_id", "external_ids", "synonyms"],
    planned: ["smiles", "inchikey", "metabolite_class", "description"],
  },
  Tissue: {
    confirmed: ["tissue_id", "tissue_name", "organ_system", "source"],
    recommended: ["project_id", "external_ids", "synonyms"],
    planned: ["description"],
  },
  CellType: {
    confirmed: ["cell_type_id", "cell_type_name", "source"],
    recommended: ["project_id", "external_ids", "synonyms"],
    planned: ["tissue_context", "description"],
  },
};

const schemaNodes = [
  { id: "Disease", label: "Disease", type: "Disease", x: 500, y: 105, source: "ontology", detail: "Disease, phenotype, pathological condition, or liver disease progression stage." },
  { id: "Gene", label: "Gene", type: "Gene", x: 150, y: 210, source: "DisGeNET", detail: "Gene or gene locus relevant to liver disease biology." },
  { id: "Protein", label: "Protein", type: "Protein", x: 300, y: 420, source: "STRING", detail: "Protein product, preferably normalized to UniProt or STRING where possible." },
  { id: "Pathway", label: "Pathway", type: "Pathway", x: 625, y: 330, source: "KEGG", detail: "Biological pathway, metabolic pathway, or pathway hierarchy term." },
  { id: "Metabolite", label: "Metabolite", type: "Metabolite", x: 850, y: 500, source: "HMDB", detail: "Metabolite or chemical compound associated with liver disease metabolism." },
  { id: "Tissue", label: "Tissue", type: "Tissue", x: 525, y: 530, source: "HPA", detail: "Tissue or anatomical context used for expression and pathology evidence." },
  { id: "CellType", label: "CellType", type: "CellType", x: 850, y: 175, source: "HPA", detail: "Cell type relevant to liver tissue context, inflammation, fibrosis, or tumor microenvironment." },
];

const schemaEdges = [
  { from: "Disease", to: "Disease", label: "progresses_to", source: "ontology", evidence: "project-defined progression model", labelOffset: [0, -10] },
  { from: "Gene", to: "Disease", label: "associated_with", source: "DisGeNET", evidence: "curated_database", labelOffset: [-20, -16] },
  { from: "Gene", to: "Protein", label: "encodes", source: "STRING", evidence: "curated_database", labelOffset: [-28, 16] },
  { from: "Protein", to: "Protein", label: "interacts_with", source: "STRING", evidence: "curated_database", labelOffset: [0, 18] },
  { from: "Gene", to: "Pathway", label: "participates_in", source: "KEGG", evidence: "curated_database", labelOffset: [8, 18] },
  { from: "Protein", to: "Pathway", label: "involved_in", source: "KEGG", evidence: "curated_database", labelOffset: [-8, -20] },
  { from: "Pathway", to: "Disease", label: "associated_with_pathogenesis", source: "PubMed/LLM", evidence: "llm_extracted_candidate", labelOffset: [22, -20] },
  { from: "Metabolite", to: "Pathway", label: "involved_in_pathway", source: "HMDB", evidence: "curated_database", labelOffset: [18, 20] },
  { from: "Metabolite", to: "Disease", label: "associated_with_metabolic_change", source: "HMDB", evidence: "literature_supported", labelOffset: [90, 20] },
  { from: "Pathway", to: "Pathway", label: "subpathway_of", source: "Reactome", evidence: "curated_database", labelOffset: [0, -35] },
  { from: "Protein", to: "Tissue", label: "expressed_in_tissue", source: "HPA", evidence: "curated_database", labelOffset: [-32, 18] },
  { from: "Protein", to: "CellType", label: "expressed_in_celltype", source: "HPA", evidence: "curated_database", labelOffset: [-65, 28] },
  { from: "CellType", to: "Tissue", label: "located_in", source: "HPA", evidence: "curated_database", labelOffset: [35, 18] },
  { from: "CellType", to: "Disease", label: "involved_in_disease", source: "PubMed/LLM", evidence: "llm_extracted_candidate", labelOffset: [14, -16] },
];

const exampleNodes = [
  { id: "healthy", label: "Healthy liver", type: "Disease", x: 95, y: 95, source: "ontology", detail: "Canonical baseline stage in the disease progression model." },
  { id: "nafld", label: "NAFLD", type: "Disease", x: 245, y: 95, source: "ontology", detail: "Early liver disease progression stage represented as a Disease entity." },
  { id: "nash", label: "NASH", type: "Disease", x: 395, y: 95, source: "ontology", detail: "Inflammatory progression stage linked by progresses_to." },
  { id: "fibrosis", label: "Fibrosis", type: "Disease", x: 545, y: 95, source: "ontology", detail: "Fibrotic progression stage." },
  { id: "cirrhosis", label: "Cirrhosis", type: "Disease", x: 695, y: 95, source: "ontology", detail: "Advanced chronic liver disease stage." },
  { id: "hcc", label: "HCC", type: "Disease", x: 845, y: 95, source: "ontology", detail: "Hepatocellular carcinoma endpoint stage for this demo." },
  { id: "pnpla3", label: "PNPLA3", type: "Gene", x: 245, y: 245, source: "DisGeNET", detail: "Example gene mapped from gene-disease association sources." },
  { id: "tnf", label: "TNF", type: "Gene", x: 395, y: 275, source: "DisGeNET", detail: "Example inflammatory gene associated with NASH-related biology." },
  { id: "tnfp", label: "TNF protein", type: "Protein", x: 535, y: 370, source: "STRING", detail: "Protein node used for PPI and pathway relations." },
  { id: "nfkb", label: "NF-kB pathway", type: "Pathway", x: 720, y: 335, source: "KEGG", detail: "Example pathway introduced by KEGG as the first pathway layer." },
  { id: "reactomeHierarchy", label: "Immune signaling", type: "Pathway", x: 870, y: 250, source: "Reactome", detail: "Example Reactome pathway hierarchy node used to extend the Pathway layer." },
  { id: "bile", label: "Bile acid", type: "Metabolite", x: 455, y: 535, source: "HMDB", detail: "Example metabolite layer for disease-related metabolic changes." },
  { id: "liver", label: "Liver tissue", type: "Tissue", x: 690, y: 535, source: "HPA", detail: "Tissue context for protein expression." },
  { id: "kupffer", label: "Kupffer cell", type: "CellType", x: 865, y: 535, source: "HPA", detail: "Cell-type context for liver inflammation and disease involvement." },
  { id: "candidate", label: "Candidate triple", type: "Pathway", x: 115, y: 435, source: "PubMed/LLM", detail: "LLM-extracted relationship stored as candidate until validation." },
];

const exampleEdges = [
  { from: "healthy", to: "nafld", label: "progresses_to", source: "ontology", evidence: "project-defined progression model", labelOffset: [0, -18] },
  { from: "nafld", to: "nash", label: "progresses_to", source: "ontology", evidence: "project-defined progression model", labelOffset: [0, -18] },
  { from: "nash", to: "fibrosis", label: "progresses_to", source: "ontology", evidence: "project-defined progression model", labelOffset: [0, -18] },
  { from: "fibrosis", to: "cirrhosis", label: "progresses_to", source: "ontology", evidence: "project-defined progression model", labelOffset: [0, -18] },
  { from: "cirrhosis", to: "hcc", label: "progresses_to", source: "ontology", evidence: "project-defined progression model", labelOffset: [0, -18] },
  { from: "pnpla3", to: "nafld", label: "associated_with", source: "DisGeNET", evidence: "curated_database", labelOffset: [-18, 8] },
  { from: "tnf", to: "nash", label: "associated_with", source: "DisGeNET", evidence: "curated_database", labelOffset: [18, 8] },
  { from: "tnf", to: "tnfp", label: "encodes", source: "STRING", evidence: "curated_database", labelOffset: [-25, -22] },
  { from: "tnfp", to: "nfkb", label: "involved_in", source: "KEGG", evidence: "curated_database", labelOffset: [0, -20] },
  { from: "nfkb", to: "reactomeHierarchy", label: "subpathway_of", source: "Reactome", evidence: "curated_database", labelOffset: [8, -18] },
  { from: "nfkb", to: "nash", label: "associated_with_pathogenesis", source: "PubMed/LLM", evidence: "llm_extracted_candidate", labelOffset: [16, -20] },
  { from: "bile", to: "cirrhosis", label: "associated_with_metabolic_change", source: "HMDB", evidence: "literature_supported", labelOffset: [-35, 36] },
  { from: "tnfp", to: "liver", label: "expressed_in_tissue", source: "HPA", evidence: "curated_database", labelOffset: [-18, 16] },
  { from: "kupffer", to: "liver", label: "located_in", source: "HPA", evidence: "curated_database", labelOffset: [0, 18] },
  { from: "kupffer", to: "nash", label: "involved_in_disease", source: "PubMed/LLM", evidence: "llm_extracted_candidate", labelOffset: [62, -46] },
  { from: "candidate", to: "fibrosis", label: "associated_with_pathogenesis", source: "PubMed/LLM", evidence: "llm_extracted_candidate", labelOffset: [-6, 24] },
];

const stages = [
  ["Healthy liver", "Order 0"],
  ["NAFLD", "Order 1"],
  ["NASH", "Order 2"],
  ["Fibrosis", "Order 3"],
  ["Cirrhosis", "Order 4"],
  ["HCC", "Order 5"],
];

let nodes = [];
let edges = [];

const svg = document.getElementById("graph");
const sourceFilter = document.getElementById("sourceFilter");
const exampleToggle = document.getElementById("exampleToggle");
const detailTitle = document.getElementById("detailTitle");
const detailText = document.getElementById("detailText");
const detailGrid = document.getElementById("detailGrid");
const nodeCount = document.getElementById("nodeCount");
const edgeCount = document.getElementById("edgeCount");
const graphTitle = document.getElementById("graphTitle");
const defaultViewBox = { x: 0, y: 0, width: 980, height: 620 };

let currentViewBox = { ...defaultViewBox };
let currentActiveId = null;
let renderedEdges = [];
let renderedNodes = [];
let dragState = null;
let panState = null;
let animationFrame = null;
let gestureScale = 1;

function cloneGraph(nodesInput, edgesInput) {
  return {
    nodes: nodesInput.map((node) => ({ ...node, renderX: node.x, renderY: node.y })),
    edges: edgesInput.map((edge) => ({ ...edge })),
  };
}

function setGraphMode(useExamples) {
  const graph = useExamples ? cloneGraph(exampleNodes, exampleEdges) : cloneGraph(schemaNodes, schemaEdges);
  nodes = graph.nodes;
  edges = graph.edges;
  currentActiveId = null;
  currentViewBox = { ...defaultViewBox };
}

function nodeById(id) {
  return nodes.find((node) => node.id === id);
}

function nodePosition(node) {
  return {
    x: node.renderX ?? node.x,
    y: node.renderY ?? node.y,
  };
}

function isVisibleBySource(item, selected) {
  return selected === "all" || item.source === selected;
}

function edgePath(edge) {
  const a = nodeById(edge.from);
  const b = nodeById(edge.to);
  const start = nodePosition(a);
  const end = nodePosition(b);
  if (edge.from === edge.to) {
    const radius = a.type === "Disease" ? 42 : 38;
    return `M ${start.x - radius * 0.35} ${start.y - radius} C ${start.x - radius * 1.25} ${start.y - radius * 1.75}, ${start.x + radius * 1.25} ${start.y - radius * 1.75}, ${start.x + radius * 0.35} ${start.y - radius}`;
  }
  const dx = end.x - start.x;
  const dy = end.y - start.y;
  const curve = Math.min(90, Math.max(-90, dx * 0.18 + dy * 0.08));
  return `M ${start.x} ${start.y} Q ${(start.x + end.x) / 2} ${(start.y + end.y) / 2 - curve} ${end.x} ${end.y}`;
}

function midpoint(edge) {
  const a = nodePosition(nodeById(edge.from));
  const b = nodePosition(nodeById(edge.to));
  const [offsetX, offsetY] = edge.labelOffset || [0, 0];
  if (edge.from === edge.to) {
    return { x: a.x + offsetX, y: a.y - 72 + offsetY };
  }
  return {
    x: (a.x + b.x) / 2 + offsetX,
    y: (a.y + b.y) / 2 + offsetY,
  };
}

function applyViewBox() {
  svg.setAttribute("viewBox", `${currentViewBox.x} ${currentViewBox.y} ${currentViewBox.width} ${currentViewBox.height}`);
}

function svgPoint(event) {
  const point = svg.createSVGPoint();
  point.x = event.clientX;
  point.y = event.clientY;
  return point.matrixTransform(svg.getScreenCTM().inverse());
}

function clearSelection() {
  const selection = window.getSelection?.();
  if (selection && selection.rangeCount > 0) {
    selection.removeAllRanges();
  }
}

function updateGraphGeometry() {
  renderedEdges.forEach(({ edge, path, label }) => {
    const labelPoint = midpoint(edge);
    path.setAttribute("d", edgePath(edge));
    label.setAttribute("x", labelPoint.x);
    label.setAttribute("y", labelPoint.y - 12);
  });

  renderedNodes.forEach(({ node, group, circle }) => {
    const position = nodePosition(node);
    const stretch = Math.min(0.18, Math.hypot(node.x - position.x, node.y - position.y) / 150);
    group.setAttribute("transform", `translate(${position.x}, ${position.y})`);
    circle.setAttribute("transform", stretch > 0.01 ? `scale(${1 + stretch}, ${1 - stretch * 0.45})` : "");
  });
}

function animateElasticNodes() {
  let shouldContinue = false;

  nodes.forEach((node) => {
    const dx = node.x - node.renderX;
    const dy = node.y - node.renderY;
    if (Math.abs(dx) > 0.2 || Math.abs(dy) > 0.2) {
      node.renderX += dx * 0.24;
      node.renderY += dy * 0.24;
      shouldContinue = true;
    } else {
      node.renderX = node.x;
      node.renderY = node.y;
    }
  });

  updateGraphGeometry();

  if (shouldContinue || dragState) {
    animationFrame = requestAnimationFrame(animateElasticNodes);
  } else {
    animationFrame = null;
  }
}

function startElasticAnimation() {
  if (!animationFrame) {
    animationFrame = requestAnimationFrame(animateElasticNodes);
  }
}

function clampNodePosition(point, offset) {
  const margin = 24;
  return {
    x: Math.max(defaultViewBox.x + margin, Math.min(defaultViewBox.x + defaultViewBox.width - margin, point.x - offset.x)),
    y: Math.max(defaultViewBox.y + margin, Math.min(defaultViewBox.y + defaultViewBox.height - margin, point.y - offset.y)),
  };
}

function clampViewBox(box) {
  const minWidth = 220;
  const maxWidth = defaultViewBox.width;
  const minHeight = minWidth * (defaultViewBox.height / defaultViewBox.width);
  const maxHeight = defaultViewBox.height;
  const width = Math.max(minWidth, Math.min(maxWidth, box.width));
  const height = Math.max(minHeight, Math.min(maxHeight, box.height));

  return {
    x: Math.max(defaultViewBox.x - 80, Math.min(defaultViewBox.x + defaultViewBox.width - width + 80, box.x)),
    y: Math.max(defaultViewBox.y - 80, Math.min(defaultViewBox.y + defaultViewBox.height - height + 80, box.y)),
    width,
    height,
  };
}

function zoomAt(point, scale) {
  const nextWidth = currentViewBox.width * scale;
  const nextHeight = currentViewBox.height * scale;
  const rx = (point.x - currentViewBox.x) / currentViewBox.width;
  const ry = (point.y - currentViewBox.y) / currentViewBox.height;

  currentViewBox = clampViewBox({
    x: point.x - nextWidth * rx,
    y: point.y - nextHeight * ry,
    width: nextWidth,
    height: nextHeight,
  });
  applyViewBox();
}

function visibleGraphData() {
  const selectedSource = sourceFilter.value;
  const visibleEdges = edges.filter((edge) => isVisibleBySource(edge, selectedSource));
  const connectedIds = new Set(visibleEdges.flatMap((edge) => [edge.from, edge.to]));
  const visibleNodes = selectedSource === "all"
    ? nodes
    : nodes.filter((node) => isVisibleBySource(node, selectedSource) || connectedIds.has(node.id));
  return { visibleEdges, visibleNodes };
}

function nearestVisibleNode(point) {
  const { visibleNodes } = visibleGraphData();
  return visibleNodes.find((node) => {
    const position = nodePosition(node);
    const radius = node.type === "Disease" ? 38 : 35;
    return Math.hypot(point.x - position.x, point.y - position.y) <= radius;
  });
}

function startPan(event) {
  if (!panState || panState.pointerId !== event.pointerId || panState.active) return;
  clearSelection();
  panState.active = true;
  svg.classList.add("panning");
  svg.setPointerCapture(event.pointerId);
}

function panTo(event) {
  if (!panState) return;
  const rect = svg.getBoundingClientRect();
  const dx = (event.clientX - panState.startClientX) * (panState.startViewBox.width / rect.width);
  const dy = (event.clientY - panState.startClientY) * (panState.startViewBox.height / rect.height);
  currentViewBox = clampViewBox({
    x: panState.startViewBox.x - dx,
    y: panState.startViewBox.y - dy,
    width: panState.startViewBox.width,
    height: panState.startViewBox.height,
  });
  applyViewBox();
}

function stopPan() {
  if (panState?.holdTimer) {
    clearTimeout(panState.holdTimer);
  }
  panState = null;
  svg.classList.remove("panning");
}

function setDetails(title, text, rows) {
  detailTitle.textContent = title;
  detailText.textContent = text;
  detailGrid.innerHTML = rows
    .map(([key, value]) => `<div><dt>${key}</dt><dd>${value}</dd></div>`)
    .join("");
}

function attributeRows(entityType) {
  const attributes = entityAttributes[entityType];
  if (!attributes) return [];
  return [
    ["Confirmed attributes", attributes.confirmed.join(", ")],
    ["Recommended attributes", attributes.recommended.join(", ")],
    ["Planned attributes", attributes.planned.join(", ")],
  ];
}

function showNodeDetails(node) {
  setDetails(node.label, node.detail, [
    ["Entity class", node.type],
    ["Mapped source", node.source],
    ["Ontology role", node.type === "Disease" ? "Progression stage or disease node" : "Biomedical entity node"],
    ...attributeRows(node.type),
  ]);
}

function renderLegend() {
  const legend = document.getElementById("legend");
  legend.innerHTML = Object.entries(classes)
    .map(([name, color]) => `<div class="legend-item"><span class="swatch" style="background:${color}"></span>${name}</div>`)
    .join("");
}

function renderTimeline() {
  document.getElementById("timeline").innerHTML = stages
    .map(([name, meta]) => `<div class="stage"><strong>${name}</strong><small>${meta}</small></div>`)
    .join("");
}

function renderGraph(activeId = null) {
  currentActiveId = activeId;
  const selectedSource = sourceFilter.value;
  const { visibleEdges, visibleNodes } = visibleGraphData();

  nodeCount.textContent = visibleNodes.length;
  edgeCount.textContent = visibleEdges.length;
  const modeLabel = exampleToggle.checked ? "example graph" : "entity schema graph";
  graphTitle.textContent = selectedSource === "all" ? `YAML ${modeLabel}` : `${selectedSource} ${modeLabel}`;
  renderedEdges = [];
  renderedNodes = [];
  applyViewBox();

  svg.innerHTML = `
    <defs>
      <marker id="arrow" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto" markerUnits="strokeWidth">
        <path d="M0,0 L0,6 L8,3 z" fill="#95a39c"></path>
      </marker>
      <marker id="arrowActive" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto" markerUnits="strokeWidth">
        <path d="M0,0 L0,6 L8,3 z" fill="#c88322"></path>
      </marker>
    </defs>
  `;

  visibleEdges.forEach((edge, index) => {
    const a = nodeById(edge.from);
    const b = nodeById(edge.to);
    const labelPoint = midpoint(edge);
    const path = document.createElementNS("http://www.w3.org/2000/svg", "path");
    const isActive = activeId === edge.from || activeId === edge.to || activeId === `edge-${index}`;
    path.setAttribute("d", edgePath(edge));
    path.setAttribute("class", `edge ${activeId && !isActive ? "dim" : ""} ${isActive ? "active" : ""}`);
    path.setAttribute("fill", "none");
    path.setAttribute("marker-end", isActive ? "url(#arrowActive)" : "url(#arrow)");
    path.addEventListener("click", () => {
      setDetails(edge.label, `${edge.source} validates this relationship against the shared YAML schema as ${edge.label}.`, [
        ["Source", edge.source],
        ["Evidence", edge.evidence],
        ["From", a.label],
        ["To", b.label],
      ]);
      renderGraph(`edge-${index}`);
    });
    svg.appendChild(path);

    const label = document.createElementNS("http://www.w3.org/2000/svg", "text");
    label.setAttribute("x", labelPoint.x);
    label.setAttribute("y", labelPoint.y - 12);
    label.setAttribute("class", `edge-label ${activeId && !isActive ? "dim" : ""}`);
    label.textContent = edge.label;
    svg.appendChild(label);
    renderedEdges.push({ edge, path, label });
  });

  visibleNodes.forEach((node) => {
    const group = document.createElementNS("http://www.w3.org/2000/svg", "g");
    const position = nodePosition(node);
    const isActive = activeId === node.id;
    const isDim = activeId && !isActive && !visibleEdges.some((edge) => (edge.from === activeId || edge.to === activeId) && (edge.from === node.id || edge.to === node.id));
    group.setAttribute("class", `node ${isActive ? "active" : ""} ${isDim ? "dim" : ""}`);
    group.setAttribute("transform", `translate(${position.x}, ${position.y})`);
    group.innerHTML = `
      <circle r="${node.type === "Disease" ? 31 : 28}" fill="${classes[node.type]}"></circle>
      <text y="52">${node.label}</text>
    `;
    const circle = group.querySelector("circle");
    group.addEventListener("pointerdown", (event) => {
      if (event.button !== 0) return;
      clearSelection();
      const point = svgPoint(event);
      dragState = {
        node,
        pointerId: event.pointerId,
        offset: {
          x: point.x - node.x,
          y: point.y - node.y,
        },
        moved: false,
      };
      group.classList.add("dragging");
      group.setPointerCapture(event.pointerId);
      event.preventDefault();
      event.stopPropagation();
      startElasticAnimation();
    });
    group.addEventListener("pointerup", () => {
      group.classList.remove("dragging");
    });
    group.addEventListener("pointercancel", () => {
      group.classList.remove("dragging");
    });
    group.addEventListener("click", () => {
      if (node.wasDragged) return;
      showNodeDetails(node);
      renderGraph(node.id);
    });
    svg.appendChild(group);
    renderedNodes.push({ node, group, circle });
  });

}

svg.addEventListener("pointerdown", (event) => {
  if (event.button !== 0) return;
  const point = svgPoint(event);
  const hitNode = nearestVisibleNode(point);
  if (hitNode) {
    clearSelection();
    dragState = {
      node: hitNode,
      pointerId: event.pointerId,
      offset: {
        x: point.x - hitNode.x,
        y: point.y - hitNode.y,
      },
      moved: false,
    };
    svg.setPointerCapture(event.pointerId);
    const rendered = renderedNodes.find((item) => item.node.id === hitNode.id);
    rendered?.group.classList.add("dragging");
    event.preventDefault();
    startElasticAnimation();
    return;
  }
  clearSelection();
  panState = {
    pointerId: event.pointerId,
    startClientX: event.clientX,
    startClientY: event.clientY,
    startViewBox: { ...currentViewBox },
    active: false,
    holdTimer: setTimeout(() => startPan(event), 140),
  };
});

svg.addEventListener("pointermove", (event) => {
  if (dragState && event.pointerId === dragState.pointerId) {
    clearSelection();
    const point = svgPoint(event);
    const next = clampNodePosition(point, dragState.offset);
    if (Math.hypot(next.x - dragState.node.x, next.y - dragState.node.y) > 1.5) {
      dragState.moved = true;
      dragState.node.wasDragged = true;
    }
    dragState.node.x = next.x;
    dragState.node.y = next.y;
    startElasticAnimation();
    return;
  }

  if (panState && event.pointerId === panState.pointerId) {
    const moved = Math.hypot(event.clientX - panState.startClientX, event.clientY - panState.startClientY);
    if (moved > 4) {
      startPan(event);
    }
    if (panState.active) {
      event.preventDefault();
      clearSelection();
      panTo(event);
    }
  }
});

svg.addEventListener("pointerup", (event) => {
  if (dragState && event.pointerId === dragState.pointerId) {
    const draggedNode = dragState.node;
    const rendered = renderedNodes.find((item) => item.node.id === draggedNode.id);
    rendered?.group.classList.remove("dragging");
    dragState = null;
    startElasticAnimation();
    setTimeout(() => {
      draggedNode.wasDragged = false;
    }, 0);
    return;
  }

  if (panState && event.pointerId === panState.pointerId) {
    stopPan();
  }
});

svg.addEventListener("click", (event) => {
  if (dragState || panState?.active) return;
  const hitNode = nearestVisibleNode(svgPoint(event));
  if (!hitNode) return;
  if (hitNode.wasDragged) return;
  showNodeDetails(hitNode);
  renderGraph(hitNode.id);
});

svg.addEventListener("pointercancel", () => {
  if (dragState) {
    dragState = null;
    startElasticAnimation();
  }
  stopPan();
});

svg.addEventListener("selectstart", (event) => {
  event.preventDefault();
  clearSelection();
});

svg.addEventListener("dragstart", (event) => {
  event.preventDefault();
  clearSelection();
});

svg.addEventListener("wheel", (event) => {
  event.preventDefault();
  clearSelection();
  const point = svgPoint(event);
  const intensity = event.ctrlKey ? 0.006 : 0.0028;
  const scale = Math.exp(event.deltaY * intensity);
  zoomAt(point, scale);
}, { passive: false });

svg.addEventListener("gesturestart", (event) => {
  event.preventDefault();
  clearSelection();
  gestureScale = 1;
});

svg.addEventListener("gesturechange", (event) => {
  event.preventDefault();
  clearSelection();
  const point = svgPoint(event);
  const nextScale = event.scale || 1;
  zoomAt(point, gestureScale / nextScale);
  gestureScale = nextScale;
});

svg.addEventListener("gestureend", () => {
  gestureScale = 1;
});

document.querySelectorAll("[data-source]").forEach((button) => {
  button.addEventListener("click", () => {
    sourceFilter.value = button.dataset.source;
    setDetails(button.dataset.source, `This layer shows how ${button.dataset.source} records validate or extend the shared ontology.`, [
      ["Mode", "Schema validation"],
      ["Graph status", "YAML consistency demo"],
    ]);
    renderGraph();
  });
});

sourceFilter.addEventListener("change", () => {
  setDetails("Filtered graph", `Showing the ${sourceFilter.value} layer.`, [
    ["Filter", sourceFilter.value],
    ["Purpose", "Inspect source mapping"],
  ]);
  renderGraph();
});

exampleToggle.addEventListener("change", () => {
  setGraphMode(exampleToggle.checked);
  setDetails(exampleToggle.checked ? "Example mode" : "Schema mode", exampleToggle.checked
    ? "Showing concrete example nodes mapped onto the ontology classes. Select a node to see its entity class attributes."
    : "Showing ontology entity classes directly. Select an entity class to inspect confirmed, recommended, and planned attributes.", [
    ["Display", exampleToggle.checked ? "Example instances" : "Entity classes"],
    ["Validation target", "ontology_v1.0.yaml"],
  ]);
  renderGraph();
});

document.getElementById("resetView").addEventListener("click", () => {
  sourceFilter.value = "all";
  currentViewBox = { ...defaultViewBox };
  setDetails("Ontology backbone", "Select a node or relation to inspect how the ontology stores entity type, source, evidence level, and YAML-valid relation semantics.", [
    ["Route", "v0.1 -> v0.7 -> v1.0 YAML"],
    ["Status", "Validation demo"],
  ]);
  renderGraph();
});

setGraphMode(false);
renderLegend();
renderTimeline();
renderGraph();
