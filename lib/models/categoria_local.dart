class CategoriaLocal {
  final String id;
  final String nombre;
  final String descripcion; 
  final String imageUrl;

  CategoriaLocal({
    required this.id,
    required this.nombre,
    required this.descripcion, 
    required this.imageUrl,
  });
}

// Datos fijos con 6 categorías y URL de imagen
final List<CategoriaLocal> categoriasFijas = [
  CategoriaLocal(
    id: '1',
    nombre: 'NIKE 1.1',
    descripcion: 'Gorras deportivas Nike con diseño moderno y ajuste cómodo.',
    imageUrl: 'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1762950181/gorrastaysazulsocuro14_mt0k0o.jpg',
  ),
  CategoriaLocal(
    id: '2',
    nombre: 'DIM & A/N',
    descripcion: 'Estilo urbano con materiales de alta calidad y acabados premium.',
    imageUrl: 'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1762988183/negraconelescudo_zzh4l9.jpg',
  ),
  CategoriaLocal(
    id: '3',
    nombre: 'BEISBOLERA PREMIUM',
    descripcion: 'Gorras clásicas de beisbol con bordados detallados y ajuste ajustable.',
    imageUrl: 'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1762910786/gorraazulgrisLa_i1dazk.jpg',
  ),
  CategoriaLocal(
    id: '4',
    nombre: 'DIAMANTE IMPORTADA',
    descripcion: 'Gorras exclusivas importadas con diseños únicos y materiales premium.',
    imageUrl: 'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1762914409/gorraLA_vz1fsr.jpg',
  ),
  CategoriaLocal(
    id: '5',
    nombre: 'PLANA IMPORTADA',
    descripcion: 'Gorras planas de estilo urbano con calidad internacional.',
    imageUrl: 'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1762995585/gorranegraheatss_mphchc.jpg',
  ),
  CategoriaLocal(
    id: '6',
    nombre: 'AGROPECUARIAS',
    descripcion: 'Diseños rurales y temáticos para amantes del campo y la naturaleza.',
    imageUrl: 'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1762916288/gorraazulcerdoverde_e10kc7.jpg',
  ),
  CategoriaLocal(
    id: '7',
    nombre: 'MULTIMARCA',
    descripcion: 'Colección variada de marcas reconocidas en una sola sección.',
    imageUrl: 'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1762957931/gorradoaradamonastery_svnsws.jpg',
  ),
  CategoriaLocal(
    id: '8',
    nombre: 'PLANA CERRADA 1.1',
    descripcion: 'Gorras planas con cierre trasero y diseño elegante para uso diario.',
    imageUrl: 'https://res.cloudinary.com/dxc5qqsjd/image/upload/v1762988567/gorranegraceltics_isriex.jpg',
  ),
];
