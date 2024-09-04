module.exports = function (grunt) {
	grunt.initConfig({
		concat: {
			js: {
				src: [
					'./scripts/plugins/lodash.js',
					'./scripts/plugins/bootstrap-context-menu.js',
					'./scripts/debugger.js',
					'./scripts/language.js',
					'./scripts/nui.js',
					'./scripts/inventory-notify.js',
					'./scripts/inventory.js',
					'./scripts/interact.js',
					'./scripts/events.js',
					'./scripts/ready.js',
				],
				dest: '../assets/app.js',
				destMin: '../assets/app.min.js',
			},
			css: {
				src: ['./styles/main.css'],
				dest: '../assets/app.css',
			},
		},
		watch: {
			scripts: {
				files: ['./**/*.js'],
				tasks: ['concat', 'terser'],
				options: {
					spawn: false,
				},
			},
			css: {
				files: './**/*.css',
				tasks: ['concat'],
				options: {
					livereload: true,
				},
			},
			html: {
				files: './html/*.html',
				tasks: ['htmlmin'],
				options: {
					livereload: true,
				},
			},
		},
		terser: {
			options: {
				compress: true,
				mangle: true,
			},
			target: {
				src: '<%= concat.js.dest %>',
				dest: '<%= concat.js.destMin %>',
			},
		},
		htmlmin: {
			dist: {
				options: {
					removeComments: true,
					collapseWhitespace: true,
				},
				files: {
					'../index.html': './html/index.html',
				},
			},
		},
	});
	grunt.loadNpmTasks('grunt-contrib-concat');
	grunt.loadNpmTasks('grunt-terser');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-htmlmin');
	grunt.registerTask('default', ['concat', 'terser', 'htmlmin']);
};
