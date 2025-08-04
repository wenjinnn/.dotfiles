return {
  init_options = {
    typescript = {
      tsdk = os.getenv('TYPESCRIPT_LIBRARY') or 'node_modules/typescript/lib',
    },
  },
}
