/**
 * Tailwind configuration for the example webapp.
 * Run the build (see package.json scripts) to generate assets/generated-tailwind.css
 */
module.exports = {
	content: [
		'../../lib/**/*.j2.html',
		'../../lib/**/*.dart',
		'../../lib/**/*.html',
		'../../lib/**/*.js',
		'../../lib/**/*.ts',
		'../../lib/**/*.vue',
		'../../lib/**/*.svelte',
		'../../lib/**/*.jsx',
		'../../lib/**/*.tsx'
	],
	theme: {
		extend: {
			colors: {
				brand: {
					50:  '#f5f8ff',
					100: '#e6efff',
					200: '#c2d9ff',
					300: '#99c1ff',
					400: '#5d9dff',
					500: '#1f78ff',
					600: '#0d60d9',
					700: '#0a4aa8',
					800: '#083878',
					900: '#052247',
					950: '#031529'
				},
				primary: {
					50:  '#f5f8ff',
					100: '#e6efff',
					200: '#c2d9ff',
					300: '#99c1ff',
					400: '#5d9dff',
					500: '#1f78ff',
					600: '#0d60d9',
					700: '#0a4aa8',
					800: '#083878',
					900: '#052247',
					950: '#031529'
				},
				accent: '#ff7d1f'
			}
		}
	},
	plugins: []
};
