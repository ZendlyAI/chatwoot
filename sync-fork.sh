#!/bin/bash
# Script para verificar y sincronizar un fork con el repo original (upstream/master)

# 1. Asegurar que estamos en feat/zendly
git checkout feat/zendly || exit 1

echo "➡️  Actualizando referencias del repo original (upstream)..."
git fetch upstream

echo "➡️  Comparando tu feat/zendly con upstream/master..."

# 2. Commits que le faltan a feat/zendly
COMMITS_MISSING=$(git log feat/zendly..upstream/master --oneline)

if [ -z "$COMMITS_MISSING" ]; then
  echo "✅ Tu branch feat/zendly ya está actualizado con upstream/master."
else
  echo "⚠️ Tu branch feat/zendly está desactualizado. Estos son los commits faltantes:"
  echo "$COMMITS_MISSING"
  
  echo ""
  read -p "¿Quieres actualizar tu feat/zendly con upstream/master usando merge? (s/n): " confirm
  if [[ "$confirm" == "s" ]]; then
    git merge upstream/master
    echo "✅ Merge completado. Ahora tu feat/zendly está actualizado."
    read -p "¿Quieres hacer push a tu fork (origin/feat/zendly)? (s/n): " push_confirm
    if [[ "$push_confirm" == "s" ]]; then
      git push origin feat/zendly
      echo "🚀 Cambios enviados a tu fork."
    fi
  else
    echo "❌ No se hizo merge. Tu rama sigue desactualizada."
  fi
fi
