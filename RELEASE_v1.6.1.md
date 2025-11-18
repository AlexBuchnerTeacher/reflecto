# Release v1.6.1 - Execution Checklist

**Status:** ✅ Ready to release (waiting for GitHub Git Service recovery)

**Current Date:** 2025-11-18  
**Branch:** fix/115-tab-navigation (5 commits ahead of main)  
**Target Version:** v1.6.1

---

## 📦 Pre-Release Checklist (COMPLETED ✅)

- [x] **Milestone cleanup**
  - [x] #109, #101 (Weekly Review) moved to v1.7.0
  - [x] v1.6.0 milestone now has 0 open issues
  
- [x] **CHANGELOG.md updated**
  - [x] Tab Navigation A11y (#115)
  - [x] Meal Time Picker 24h Format (#118)
  - [x] Debounce Standardization (#116)
  - [x] Collapsible Cards (#114)
  - [x] Custom Habit Order (#91)
  - [x] CI/CD Improvements documentation
  - [x] Issue management and cleanup

- [x] **Version bumped**
  - [x] pubspec.yaml: 1.5.0+4 → 1.6.1+7

- [x] **Branch prepared**
  - [x] 5 commits on fix/115-tab-navigation
  - [x] Last commit: `8ceaf31` "chore: Prepare release v1.6.1"

---

## 🚀 Release Execution (WHEN GITHUB RECOVERS)

### Step 1: Check GitHub Status ⏰

```bash
# Check if GitHub Git Service is back online
gh api https://www.githubstatus.com/api/v2/status.json
```

**Expected:** `"indicator": "none"` or `"minor"` (not "major")

---

### Step 2: Push Branch 📤

```bash
# Push fix/115-tab-navigation branch
git push -u origin fix/115-tab-navigation
```

**Expected Output:**
```
Enumerating objects: XX, done.
...
To https://github.com/AlexBuchnerTeacher/reflecto.git
 * [new branch]      fix/115-tab-navigation -> fix/115-tab-navigation
```

---

### Step 3: Create Pull Request 🔀

```bash
# Create PR via GitHub CLI
gh pr create \
  --title "Release v1.6.1: UX & Accessibility Improvements" \
  --body "## 🚀 Release v1.6.1

### Features & Fixes
- ✅ Tab Navigation A11y (#115) - Linear keyboard navigation for desktop users
- ✅ Meal Time Picker 24h Format (#118) - Force German 24h format (HH:mm)
- ✅ Debounce Standardization (#116) - Consistent 300ms debounce
- ✅ Collapsible Cards (#114) - Mobile-friendly card collapse
- ✅ Custom Habit Order (#91) - Drag & drop with fixed category colors

### Infrastructure
- 📝 CI/CD Improvements documented (docs/CI_CD_IMPROVEMENTS.md)
- 📝 Issue management: #102, #103, #107 cleaned up
- 📝 New test issues created: #120, #121, #122

### Milestone
- Closes v1.6.0 milestone (8/8 issues complete)
- Weekly Review (#109, #101) moved to v1.7.0

### Testing
- Tests passing on main branch (27/27)
- CI will run automatically on merge

### Release Notes
See CHANGELOG.md for full details." \
  --base main \
  --head fix/115-tab-navigation
```

**Expected Output:**
```
https://github.com/AlexBuchnerTeacher/reflecto/pull/XXX
```

---

### Step 4: Review & Merge 👀

**Option A: Auto-Merge (if CI passes)**
```bash
# Enable auto-merge
gh pr merge --auto --squash
```

**Option B: Manual Review**
1. Open PR in browser
2. Review changes
3. Wait for CI to pass
4. Click "Squash and merge"

---

### Step 5: Switch to Main & Pull 🔄

```bash
# Switch to main and pull merged changes
git checkout main
git pull origin main
```

**Expected:** main now contains all v1.6.1 changes

---

### Step 6: Create & Push Tag 🏷️

```bash
# Create annotated tag
git tag -a v1.6.1 -m "Release v1.6.1: UX & Accessibility

- Tab Navigation A11y (#115)
- Meal Time Picker 24h (#118)  
- Debounce Standardization (#116)
- Collapsible Cards (#114)
- Custom Habit Order (#91)
- CI/CD Improvements

See CHANGELOG.md for full details."

# Push tag (triggers release.yml workflow)
git push origin v1.6.1
```

**Expected Output:**
```
Total 0 (delta 0), reused 0 (delta 0)
To https://github.com/AlexBuchnerTeacher/reflecto.git
 * [new tag]         v1.6.1 -> v1.6.1
```

---

### Step 7: Verify Release 🎉

```bash
# Check release was created
gh release view v1.6.1
```

**Expected:**
- ✅ Release created with auto-generated notes
- ✅ Web build artifact attached
- ✅ CHANGELOG.md updated automatically (via release.yml)

**Or open in browser:**
```bash
gh release view v1.6.1 --web
```

---

## 📊 Post-Release Actions

### 1. Close Milestone
```bash
# Close v1.6.0 milestone
gh api -X PATCH /repos/AlexBuchnerTeacher/reflecto/milestones/7 \
  -f state=closed
```

### 2. Create v1.6.2 Milestone (Optional)
```bash
# For potential hotfixes
gh api -X POST /repos/AlexBuchnerTeacher/reflecto/milestones \
  -f title="v1.6.2" \
  -f description="Hotfixes & Minor Improvements"
```

### 3. Update ROADMAP.md
- Mark v1.6.0 as completed
- Update v1.7.0 status

### 4. Announce (Optional)
- GitHub Discussions
- Social Media
- User communication

---

## 🐛 Troubleshooting

### Problem: GitHub still returning 500/503
**Solution:** Wait longer, check https://www.githubstatus.com

### Problem: PR merge conflicts
**Solution:**
```bash
git checkout fix/115-tab-navigation
git rebase main
git push -f origin fix/115-tab-navigation
```

### Problem: CI fails on PR
**Solution:** Check error logs, fix locally, push again

### Problem: Tag already exists
**Solution:**
```bash
# Delete local tag
git tag -d v1.6.1

# Delete remote tag
git push origin :refs/tags/v1.6.1

# Recreate tag
git tag -a v1.6.1 -m "..."
git push origin v1.6.1
```

---

## 📝 Summary

**Total Changes in v1.6.1:**
- 5 Issues closed: #115, #118, #116, #114, #91
- 3 New test issues created: #120, #121, #122
- 2 Issues moved to v1.7.0: #109, #101
- 1 New documentation: CI_CD_IMPROVEMENTS.md
- 5 Commits on release branch
- 8 Files changed

**Release includes:**
- ✅ Accessibility improvements
- ✅ Bug fixes
- ✅ UX enhancements
- ✅ Infrastructure documentation
- ✅ Test strategy improvements

**Next Version:** v1.7.0 (Scaling & UX - includes Weekly Review #109, #101, Push Notifications #47)

---

**Ready to execute when GitHub Git Service recovers!** 🚀
