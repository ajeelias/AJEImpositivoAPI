# Git Workflow - Pull Request Process

## Repository Configuration

**Repository**: https://github.com/ajeelias/AJEImpositivoAPI
**Visibility**: Public
**Branch**: main (protected)

## Branch Protection Rules ✅

La rama `main` está protegida con las siguientes reglas:

### ✅ Pull Request Reviews
- **Aprobaciones requeridas**: 1 (UNA aprobación necesaria)
- **Descartar aprobaciones obsoletas**: ✅ Habilitado (si hay nuevos commits, se descartan aprobaciones previas)
- **Requiere aprobación del último push**: ❌ Deshabilitado
- **No requiere code owners**: ❌ Deshabilitado (cualquier colaborador puede aprobar)

### ✅ Protecciones Adicionales
- **Enforce admins**: ❌ Deshabilitado (el owner/administrador puede hacer bypass de las reglas)
- **Historial lineal requerido**: ✅ No se permiten merge commits, solo rebase
- **Force push**: ❌ Bloqueado
- **Eliminación de rama**: ❌ Bloqueado

## Workflow de Desarrollo

### 1. Crear una nueva rama para cambios

```bash
# Crear y cambiar a nueva rama
git checkout -b feature/nueva-funcionalidad

# O para bugs
git checkout -b fix/corregir-error
```

### 2. Realizar cambios y commits

```bash
# Hacer cambios en archivos...
git add .
git commit -m "Descripción del cambio

Detalles adicionales del cambio realizado.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 3. Push de la rama

```bash
git push -u origin feature/nueva-funcionalidad
```

### 4. Crear Pull Request

```bash
# Usando gh CLI
gh pr create --title "Título del PR" --body "Descripción detallada"

# O vía web en: https://github.com/ajeelias/AJEImpositivoAPI/pulls
```

### 5. Proceso de Revisión

1. **Asignar revisores**: Mínimo 1 persona debe revisar
2. **Revisor aprueba**: El revisor debe dar "Approve"
3. **Si hay cambios solicitados**: Realizar commits adicionales
   - ⚠️ Las aprobaciones previas se descartarán automáticamente
   - Necesitarás una nueva aprobación
4. **Merge**: Una vez con 1 aprobación, se puede hacer merge
5. **Owner/Admin**: El propietario o administrador puede hacer merge sin aprobaciones si es necesario

### 6. Merge del Pull Request

```bash
# Via CLI (después de aprobaciones)
gh pr merge --rebase

# O vía web en GitHub
```

## Comandos Útiles

### Ver estado de PRs

```bash
# Ver todos los PRs
gh pr list

# Ver detalles de un PR
gh pr view 123

# Ver checks y aprobaciones
gh pr checks
gh pr review --list
```

### Actualizar rama con cambios de main

```bash
# Estando en tu rama de feature
git fetch origin
git rebase origin/main

# Si hay conflictos, resolverlos y continuar
git rebase --continue
```

### Cerrar un PR sin merge

```bash
gh pr close 123
```

## Notas Importantes

⚠️ **IMPORTANTE**: No se puede hacer push directo a `main`. Todos los cambios DEBEN pasar por Pull Request.

✅ **1 APROBACIÓN REQUERIDA**: El merge se habilita después de que 1 revisor apruebe el PR.

👑 **OWNER/ADMIN BYPASS**: El propietario o administradores del repositorio pueden hacer merge sin aprobaciones si es necesario.

⚠️ **Nuevos commits = Nueva aprobación**: Si haces push de nuevos commits después de recibir aprobación, la aprobación se descarta y necesitarás una nueva.

✅ **Historial lineal**: Solo se permite rebase merge, manteniendo un historial limpio sin merge commits.

## Colaboradores

Para añadir colaboradores al repositorio:

```bash
# Añadir colaborador
gh api repos/ajeelias/AJEImpositivoAPI/collaborators/USERNAME -X PUT

# O vía web: Settings > Collaborators > Add people
```

---

**Alejandro J. Elías -- Director -- DeveloperTeam Software Solutions**
