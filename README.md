# Octorunner: Self-Hosted GitHub Actions Runner

**Octorunner** is a self-hosted GitHub Actions runner built using Docker. It simplifies deploying and managing custom runners for your repositories by leveraging a containerized environment. This setup provides a non-root, secure runner with preinstalled dependencies.

---

## Features

- **Non-root User**: Runs as a non-root user for enhanced security.
- **Preinstalled Dependencies**: Includes essential tools like Python and GitHub Actions runner dependencies.
- **Dynamic Configuration**: Automatically registers with a GitHub repository using environment variables.
- **Graceful Cleanup**: Handles runner removal upon termination.

---

## Prerequisites

- Docker installed on your host machine.
- A GitHub repository where the runner will be registered.
- A GitHub Personal Access Token with `repo` and `workflow` scopes.

---

## Usage

### Run the Container

Run the container with the required environment variables:
```bash
docker run -d \
  --name ghcr.io/wesleyem/octorunner:latest \
  -e REPO="username/repository" \
  -e TOKEN="ghp_yourgithubtoken" \
  octorunner
```

- `REPO`: The full name of your GitHub repository (e.g., `username/repository`).
- `TOKEN`: Your GitHub Personal Access Token with `repo` and `workflow` scopes.

### Stop the Runner

To stop and remove the runner:
```bash
docker stop octorunner && docker rm octorunner
```

### With Docker Compose

docker-compose.yaml
```yaml
---
services:
  github-runner:
    container_name: github-runner
    image: ghcr.io/wesleyem/octorunner:latest
    environment:
      REPO: ${REPOSITORY}
      TOKEN: ${RUNNER_TOKEN}
```

.env file
```
REPOSITORY=your_github_username/your_repo_name
RUNNER_TOKEN=your_fine-grained_pat
```

---

## Configuration Details

### Environment Variables

- `REPO`: The GitHub repository where the runner should register (format: `username/repo`).
- `TOKEN`: A GitHub Personal Access Token with permissions to register a runner.

---

## How It Works

1. **Image Build**:
   - The Dockerfile installs all necessary dependencies.
   - The GitHub Actions runner is downloaded and prepared for configuration.

2. **Container Runtime**:
   - On startup, the `start.sh` script dynamically retrieves a registration token for the specified repository.
   - The runner registers with the GitHub repository and starts listening for workflow jobs.

3. **Graceful Shutdown**:
   - Signal traps (`INT` and `TERM`) ensure the runner deregisters when the container is stopped.

---

## Development and Contribution

Contributions are welcome! Feel free to open issues or submit pull requests to improve Octorunner.

---

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

Let me know if you need any further adjustments!