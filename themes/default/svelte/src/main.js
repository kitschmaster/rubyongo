import App from './App.svelte';

const app = new App({
	target: document.getElementById("js-svelte-app"),
	props: {
		c: 1
	}
});

export default app;