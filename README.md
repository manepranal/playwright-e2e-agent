# Playwright E2E Test Generator Agent

A Claude Code agent that auto-generates Playwright E2E tests for the bolt project from a YouTrack ticket or pasted test plan.

## What it does

1. Accepts a YouTrack ticket URL/ID or pasted test plan as input
2. Asks for branch name, target environment, and feature flag upfront
3. Reads source code (`src/components`, `src/routes`, `src/query`) to understand the feature
4. Creates a test plan if one doesn't exist, and posts it to YouTrack
5. Checks for duplicate tests across the entire project before writing anything
6. Writes `.spec.ts` files using the Runner builder pattern
7. Writes POM classes extending `AbstractPage`
8. Lints and formats all generated files
9. Creates YouTrack sub-issues per test case
10. Prints the exact run command for the chosen environment

---

## Prerequisites

- [Claude Code CLI](https://claude.ai/code) installed and authenticated
- Access to the bolt project at `/Users/pranalmane/bolt`
- YouTrack MCP server configured (for ticket fetching and sub-issue creation)
- Node.js and Yarn installed in the bolt project

---

## Setup

```bash
git clone https://github.com/manepranal/playwright-e2e-agent.git
cd playwright-e2e-agent
chmod +x run.sh
```

Make sure Claude Code is installed:
```bash
npm install -g @anthropic-ai/claude-code
```

---

## Usage

### Interactive mode (recommended)

```bash
cd ~/playwright-e2e-agent
./run.sh
```

Then type or paste any of:
- A YouTrack ticket URL: `https://realbrokerage.youtrack.cloud/issue/RV2-12345`
- A YouTrack ticket ID: `RV2-12345`
- A pasted test plan (any text describing flows and acceptance criteria)

### Non-interactive mode (pass ticket as argument)

```bash
./run.sh "RV2-12345"
```

---

## Workflow

```
Step 0   Ask for branch, environment, and feature flag
Step 1   Fetch the YouTrack ticket (summary, description, sub-issues, comments)
Step 1b  Understand the feature by reading src/ code (components, routes, API calls)
Step 2   Create a test plan (or extract existing) and post to YouTrack
Step 3   Derive test cases from the plan
Step 4   Mandatory duplicate check — grep all spec files, skip already-covered cases
Step 5   Resolve spec and POM file paths
Step 6   Read one nearby spec for local style conventions
Step 7   Write the .spec.ts file (Runner builder pattern)
Step 8   Write the POM class(es) extending AbstractPage
Step 9   Lint and format (yarn lint, yarn prettier)
Step 10  Create YouTrack sub-issues per test case
Step 11  Print summary with run command
```

---

## Supported environments

| Environment | URL | Config file |
|------------|-----|-------------|
| local | http://localhost:3003 | `playwright.config.ts` |
| team1 | https://bolt.team1realbrokerage.com | `playwright.team1.config.ts` |
| team2 | https://bolt.team2realbrokerage.com | `playwright.team2.config.ts` |
| team3 | https://bolt.team3realbrokerage.com | `playwright.team3.config.ts` |
| team4 | https://bolt.team4realbrokerage.com | `playwright.team4.config.ts` |
| team5 | https://bolt.team5realbrokerage.com | `playwright.team5.config.ts` |
| play / stage | https://bolt.playrealbrokerage.com | `playwright.play.config.ts` |

**First-time auth setup for team2–5 and play:**

```bash
cd /Users/pranalmane/bolt
CI=true npx playwright test --config playwright.team2.config.ts --project=auth
```

The `CI=true` flag forces the auth setup to regenerate `.auth/*.json` cookie files for the correct domain.

---

## Code patterns used

### Runner builder pattern (spec files)

```typescript
Runner.builder<{ agentId: string }>()
  .tags(Tags.ONBOARDING)
  .onDesktopDevice()
  .asUSAgent()
  .withFeatureFlagsEnabled(['SOME_FLAG'])   // only when feature flag applies
  .bootstrap(async ({ page, userCredentials }) => {
    // set up test data
    return { agentId: userCredentials.id };
  })
  .run('feature-name', async ({ test }) => {
    test('TC-001: happy path', async ({ page, bootstrapData }) => {
      const featurePage = new FeatureNamePage(page);
      await featurePage.navigate();
      // ...
    });
  });
```

### POM (extends AbstractPage)

```typescript
export class FeatureNamePage extends AbstractPage {
  readonly submitButton: Locator;

  constructor(page: Page) {
    super(page);
    this.submitButton = page.getByRole('button', { name: /submit/i });
  }

  async navigate() {
    await this.page.goto('/the-route');
  }
}
```

---

## Hard rules (enforced by the agent)

- Never import `test` directly from `@playwright/test` — always use the Runner pattern
- Never use `page.locator('text=...')` — use `getByText()` or `getByRole()`
- Never hardcode base URLs — use relative paths (`/transactions`)
- Never use `page.waitForTimeout()` — use Playwright-native waiting
- Never put raw locators inside test methods — always in the POM constructor
- Always check for duplicate tests before writing any new file
- Always read source code before writing tests (Step 1b)

---

## Project structure

```
playwright-e2e-agent/
├── CLAUDE.md        ← Agent instructions (the "brain")
├── run.sh           ← Entry point script
└── README.md        ← This file
```

The agent writes all generated test files directly into `/Users/pranalmane/bolt/playwright/`.
