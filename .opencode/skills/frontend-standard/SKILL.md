---
name: frontend standards
description: Use when generating UI components, styling elements, or building layouts.
---

# Frontend Standards

## Stack
- React 18+ with functional components and hooks
- Tailwind CSS (no custom CSS unless absolutely necessary)
- TypeScript strict mode
- shadcn/ui for base components

## Component structure
- One component per file
- Props interface exported and named [ComponentName] Props
- Default export for the component
- Co-located test file

## Accessibility
- All interactive elements must be keyboard-navigable
- Images require alt text
- Forms require associated labels
- Color alone must not convey meaning
- Components should comply with WCAG standards.
