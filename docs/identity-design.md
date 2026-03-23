# Identity Design — Azure Zero Trust Platform

## Overview

This setup uses group-based RBAC and Conditional Access to control who can access Azure resources. Access is managed through groups, not individual users, to keep things scalable and easier to audit.

---

## RBAC Model

### Groups

- **Platform-Admins**
  - Contributor on the resource group
  - Full control for platform work

- **App-Users**
  - Reader on the resource group
  - Can view resources but not modify

- **Contractors**
  - Reader on the resource group
  - Limited access with additional restrictions

### Scope

All roles are assigned at the **resource group level (`rg-az-devsecops-platform`)** to limit blast radius and avoid over-permissioning.

---

## Access Flow

User → Group → Role → Resource

Users are added to groups, and permissions come from the group. No direct role assignments to users.

---

## Conditional Access

Contractors are required to use MFA for all cloud apps.

---

## Guest Access (B2B)

External users are invited into Entra ID, added to the Contractors group, and inherit access through RBAC. MFA is enforced through Conditional Access.

---

## Notes / Improvements

- Replace Contributor with more granular roles later
- Add PIM for admin access
- Expand Conditional Access (device compliance, location)