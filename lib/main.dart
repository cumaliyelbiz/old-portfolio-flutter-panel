import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CounterModel(),
      child: const MyApp(),
    ),
  );
}

class CounterModel with ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    _counter++;
    notifyListeners(); // Durum değiştiğinde dinleyicileri bilgilendir
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Cumali YELBİZ',
      home: MyHomePage(title: 'Cumali Yelbiz'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int activeIndex = 0;
  final List<NavigationItem> items = [
    NavigationItem(Icons.person, 'Hakkımda', const AboutPage()),
    NavigationItem(Icons.work, 'Projeler', const ProjectsPage()),
    NavigationItem(Icons.assignment, 'Çözümler', const SolutionsPage()),
    NavigationItem(Icons.stars, 'Beceriler', const SkillsPage()),
  ];

  void _toggle(int index) {
    if (activeIndex != index) {
      setState(() {
        activeIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text(items[activeIndex].title)),
      body: items[activeIndex].page,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.01),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: Colors.grey.withOpacity(0.15)),
        ),
        child: BottomAppBar(
          color: Colors.transparent,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(items.length, (index) {
                return Expanded(
                  child: SizedBox(
                    height: 70,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // İkon
                            AnimatedOpacity(
                              opacity: activeIndex == index ? 0.0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: IconButton(
                                icon: Icon(items[index].icon,
                                    color: const Color(0xFF424242)),
                                onPressed: () => _toggle(index),
                              ),
                            ),
                            // Metin
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              transform: Matrix4.translationValues(
                                0, // X kaydırma
                                activeIndex == index ? 0 : 50, // Y kaydırma
                                0,
                              ),
                              child: Text(
                                items[index].title,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: activeIndex == index
                                      ? const Color(0xFF000000)
                                      : const Color(
                                          0xFF424242), // Seçili veya diğer renkler
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              })),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final String title;
  final Widget page;

  NavigationItem(this.icon, this.title, this.page);
}

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  AboutPageState createState() => AboutPageState();
}

class AboutPageState extends State<AboutPage> {
  final TextEditingController _controller = TextEditingController();
  double _fontSize = 18;
  FontWeight _fontWeight = FontWeight.normal;
  TextAlign _textAlign = TextAlign.left;
  String aboutText = "";

  @override
  void initState() {
    fetchAboutText();
    super.initState();
  }

  void saveAboutText(int id, String description) {
    updateAboutText(id, description);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Hakkımda yazısı güncellendi.')),
    );
  }

  Future<void> updateAboutText(int id, String description) async {
    final updatedProject = {
      'description': description,
    };

    final response = await http.put(
      Uri.parse('http://localhost:3000/mobile/about/$id'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json'
      },
      body: json.encode(updatedProject),
    );

    if (response.statusCode == 200) {
      setState(() {
        fetchAboutText();
      });
    } else {
      throw Exception('Güncelleme işlemi başarısız oldu');
    }
  }

  Future<void> fetchAboutText() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/mobile/about'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );
    if (response.statusCode == 200) {
      setState(() {
        aboutText = json.decode(response.body)[0]['description'];
        _controller.text = aboutText;
      });
    } else {
      throw Exception('Silme işlemi başarısız oldu');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hakkımda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              saveAboutText(1, _controller.text);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.format_bold),
                  onPressed: () {
                    setState(() {
                      _fontWeight = _fontWeight == FontWeight.bold
                          ? FontWeight.normal
                          : FontWeight.bold;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.format_align_left),
                  onPressed: () {
                    setState(() {
                      _textAlign = TextAlign.left;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.format_align_center),
                  onPressed: () {
                    setState(() {
                      _textAlign = TextAlign.center;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.format_align_right),
                  onPressed: () {
                    setState(() {
                      _textAlign = TextAlign.right;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.text_fields),
                  onPressed: () {
                    setState(() {
                      _fontSize =
                          _fontSize == 18 ? 24 : 18; // Basit bir boyut değişimi
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Hakkımda yazınızı buraya girin...',
                    hintStyle: TextStyle(color: Colors.grey),
                    contentPadding: EdgeInsets.all(16),
                  ),
                  style:
                      TextStyle(fontSize: _fontSize, fontWeight: _fontWeight),
                  textAlign: _textAlign,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key});

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage>
    with TickerProviderStateMixin {
  List<dynamic> projects = [];
  List<int> programmingLanguages = [];

  Future<void> fetchProjects() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/mobile/projects'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );

    if (response.statusCode == 200) {
      setState(() {
        // Projeleri güncelle
        projects = json.decode(response.body);

        // Listeleri güncelle
        _showButtonsList = List<bool>.filled(projects.length, false);
        _controllers =
            List<AnimationController>.generate(projects.length, (index) {
          return AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          );
        });
        _animations =
            List<Animation<Offset>>.generate(projects.length, (index) {
          return Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controllers[index],
            curve: Curves.easeInOut,
          ));
        });
      });
    } else {
      throw Exception('Veri alınamadı');
    }
  }

  Future<void> deleteProject(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/mobile/projects/$id'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );
    if (response.statusCode == 200) {
      fetchProjects(); // Yenile
    } else {
      throw Exception('Silme işlemi başarısız oldu');
    }
  }

  Future<void> addProject() async {
    final newProject = {
      'project_name': 'Yeni Proje',
      'description': 'Proje Açıklaması',
      'link': 'https://example.com',
      'is_visibility': 0,
      'languages': [1] // Örnek dil ID'leri
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/mobile/projects'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json'
      },
      body: json.encode(newProject),
    );

    if (response.statusCode == 200) {
      fetchProjects(); // Yenile
    } else {
      throw Exception('Ekleme işlemi başarısız oldu');
    }
  }

  Future<void> changeVisibilityProject(int id, int isVisibility) async {
    int visibility = isVisibility == 1 ? 0 : 1;
    debugPrint(isVisibility == 1 ? "Kapatıldı" : "Aktifleştirildi");

    final response = await http.put(
      Uri.parse(
          'http://localhost:3000/mobile/projects/$id/visibility'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json',
      },
      body: json.encode({'visibility': visibility}),
    );

    if (response.statusCode == 200) {
      debugPrint('Proje görünürlüğü başarıyla güncellendi.');
      setState(() {
        fetchProjects();
      });
    } else {
      throw Exception('Görünürlük güncelleme hatası: ${response.statusCode}');
    }
  }

  Future<void> updateProject(int id, String projectName, String description,
      String link, List<String> languages) async {
    final updatedProject = {
      'project_name': projectName,
      'description': description,
      'link': link,
      'languages': languages
    };

    final response = await http.put(
      Uri.parse('http://localhost:3000/mobile/projects/$id'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json'
      },
      body: json.encode(updatedProject),
    );

    if (response.statusCode == 200) {
      fetchProjects(); // Yenile
    } else {
      throw Exception('Güncelleme işlemi başarısız oldu');
    }
  }

  List<bool> _showButtonsList = [];
  List<AnimationController> _controllers = [];
  List<Animation<Offset>> _animations = [];

  @override
  void initState() {
    super.initState();
    fetchProjects();
    for (int i = 0; i < projects.length; i++) {
      _initializeAnimation(i);
    }
  }

  void _initializeAnimation(int index) {
    final controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    )..addStatusListener((status) {
        if (status == AnimationStatus.dismissed) {
          setState(() {
            _showButtonsList[index] = false;
          });
        }
      });

    final animation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));

    _controllers.add(controller);
    _animations.add(animation);
  }

  void _toggleButtons(int index) {
    setState(() {
      _showButtonsList[index] = !_showButtonsList[index];

      if (_showButtonsList[index]) {
        // Buton açılırken
        if (_controllers[index].isDismissed) {
          _controllers[index].forward();
        }
      } else {
        // Buton kapanırken
        if (_controllers[index].isCompleted) {
          // Önce animasyonu bitir
          _controllers[index].value = 0; // Animasyonu sıfırla
          _controllers[index].reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 244, 246, 1),
      appBar: AppBar(
        title: const Text('Projeler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => addProject(),
          ),
        ],
      ),
      body: projects.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: projects.length,
              itemBuilder: (context, index) {
                // Listeleri ilk oluşturduğumuzda projelerin sayısı ile senkronize et
                if (_showButtonsList.length < projects.length) {
                  _showButtonsList.add(false);
                  _initializeAnimation(index);
                }

                final project = projects[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 10),
                        blurRadius: 15,
                        spreadRadius: -3,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 80, // Minimum yükseklik
                        ),
                        child: _showButtonsList[index]
                            ? SlideTransition(
                                position: _animations[index],
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        changeVisibilityProject(project['id'],
                                            project['is_visibility']);
                                      },
                                      icon: Icon(
                                        project['is_visibility'] == 1
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: project['is_visibility'] == 1
                                            ? Colors.cyan
                                            : Colors.blueGrey,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        fetchProjects();
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  ProjectsEditPage(project)),
                                        );

                                        if (result == true) {
                                          fetchProjects(); // Geri döndüğünde projeleri çek
                                        }
                                      },
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title:
                                                    const Text("Silme Onayı"),
                                                content: const Text(
                                                    "Bu projeyi silmek istediğinize emin misiniz?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                    child: const Text("Hayır"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () {
                                                      deleteProject(
                                                          project['id']);
                                                      Navigator.of(context)
                                                          .pop(); // Popup'ı kapat
                                                    },
                                                    child: const Text('Evet'),
                                                  ),
                                                ],
                                              );
                                            });
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 50,
                                      child: VerticalDivider(
                                        thickness: 1,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      onPressed: () => _toggleButtons(index),
                                    ),
                                  ],
                                ),
                              )
                            : Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                child: ListTile(
                                  title: Text(project['project_name'] ?? ''),
                                  subtitle: Text(project['description'] ?? ''),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    onPressed: () => _toggleButtons(index),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class ProjectsEditPage extends StatefulWidget {
  final Map<String, dynamic> project;
  const ProjectsEditPage(this.project, {super.key});

  @override
  State<ProjectsEditPage> createState() => _ProjectsEditPageState();
}

class _ProjectsEditPageState extends State<ProjectsEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;

  List<int> _selectedLanguages = [];
  Map<String, int> _availableLanguages = {};

  @override
  void initState() {
    super.initState();

    _nameController =
        TextEditingController(text: widget.project['project_name']);
    _descriptionController =
        TextEditingController(text: widget.project['description']);
    _linkController = TextEditingController(text: widget.project['link']);

    var languages = widget.project['languages'];

    // Eğer 'languages' bir String ise, virgülle ayırarak bir liste oluştur
    if (languages is String) {
      _selectedLanguages =
          languages.split(',').map((lang) => int.parse(lang.trim())).toList();
    } else if (languages is List) {
      // Eğer zaten bir liste ise, integer olarak dönüştür
      _selectedLanguages =
          List<int>.from(languages.map((lang) => int.parse(lang.toString())));
    } else {
      _selectedLanguages = []; // Varsayılan boş liste
    }

    fetchProgrammingLanguages(); // Yazılım dillerini çek
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> fetchProgrammingLanguages() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/mobile/programminglanguages'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );

    if (response.statusCode == 200) {
      setState(() {
        // Yazılım dillerini güncelle
        List<dynamic> languages = json.decode(response.body);
        _availableLanguages = {
          for (var lang in languages)
            lang['name']: lang['id'], // Dillerin adını ve ID'sini eşleştir
        };
      });
    } else {
      throw Exception('Veri alınamadı');
    }
  }

  Future<void> updateProject(int id, String projectName, String description,
      String link, List<int> languages) async {
    final updatedProject = {
      'project_name': projectName,
      'description': description,
      'link': link,
      'languages': languages
    };

    final response = await http.put(
      Uri.parse('http://localhost:3000/mobile/projects/$id'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json'
      },
      body: json.encode(updatedProject),
    );

    if (response.statusCode == 200) {
      // Güncelleme başarılı
      debugPrint('Proje güncellendi.');
    } else {
      throw Exception(
          'Güncelleme işlemi başarısız oldu: ${response.statusCode}');
    }
  }

  void _saveProject() {
    if (_formKey.currentState!.validate()) {
      String updatedName = _nameController.text;
      String updatedDescription = _descriptionController.text;
      String updatedLink = _linkController.text;

      updateProject(widget.project['id'], updatedName, updatedDescription,
          updatedLink, _selectedLanguages);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proje güncellendi: $updatedName')),
      );

      Navigator.pop(context, true);
    }
  }

  void _addLanguage(int languageId) {
    setState(() {
      _selectedLanguages.add(languageId);
    });
  }

  void _removeLanguage(int languageId) {
    setState(() {
      _selectedLanguages.remove(languageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proje Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProject,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Proje Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Proje adı boş olamaz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration:
                    const InputDecoration(labelText: 'Proje Açıklaması'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama boş olamaz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(labelText: 'Proje Linki'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Link boş olamaz';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Seçili Diller:'),
              Wrap(
                spacing: 8.0,
                runSpacing: 4.0,
                children: _selectedLanguages.map((languageId) {
                  // Anahtarın mevcut olup olmadığını kontrol et
                  if (_availableLanguages.values.contains(languageId)) {
                    String languageName = _availableLanguages.keys.firstWhere(
                      (key) => _availableLanguages[key] == languageId,
                      orElse: () => 'Bilinmeyen Dil', // Varsayılan değer
                    );
                    return Chip(
                      label: Text(languageName),
                      onDeleted: () => _removeLanguage(languageId),
                    );
                  } else {
                    return Container(); // Eğer dil yoksa boş bir widget döndür
                  }
                }).toList(),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Dil Seçin'),
                items: _availableLanguages.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                onChanged: (int? selectedLanguageId) {
                  if (selectedLanguageId != null &&
                      !_selectedLanguages.contains(selectedLanguageId)) {
                    _addLanguage(selectedLanguageId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SolutionsPage extends StatefulWidget {
  const SolutionsPage({super.key});

  @override
  State<SolutionsPage> createState() => _SolutionsPageState();
}

class _SolutionsPageState extends State<SolutionsPage>
    with TickerProviderStateMixin {
  List<dynamic> solutions = [];
  List<bool> _showButtonsList = [];
  List<AnimationController> _controllers = [];
  List<Animation<Offset>> _animations = [];

  @override
  void initState() {
    super.initState();
    fetchSolutions();
  }

  Future<void> fetchSolutions() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/mobile/solutions'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );

    if (response.statusCode == 200) {
      setState(() {
        solutions = json.decode(response.body);
        _showButtonsList = List<bool>.filled(solutions.length, false);
        _controllers =
            List<AnimationController>.generate(solutions.length, (index) {
          return AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
          );
        });
        _animations =
            List<Animation<Offset>>.generate(solutions.length, (index) {
          return Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _controllers[index],
            curve: Curves.easeInOut,
          ));
        });
      });
    } else {
      throw Exception('Veri alınamadı');
    }
  }

  Future<void> deleteSolution(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/mobile/solutions/$id'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );
    if (response.statusCode == 200) {
      fetchSolutions(); // Yenile
    } else {
      throw Exception('Silme işlemi başarısız oldu');
    }
  }

  Future<void> addSolution() async {
    final newSolution = {
      'project_name': 'Yeni Çözüm',
      'project_description': 'Çözüm Açıklaması',
      'project_link': 'https://example.com',
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/mobile/solutions'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json'
      },
      body: json.encode(newSolution),
    );

    if (response.statusCode == 200) {
      fetchSolutions(); // Yenile
    } else {
      throw Exception('Ekleme işlemi başarısız oldu');
    }
  }

  Future<void> changeVisibilitySolution(int id, int isVisible) async {
    int visibility = isVisible == 1 ? 0 : 1; // Mevcut duruma göre değiştir

    final response = await http.put(
      Uri.parse(
          'http://localhost:3000/mobile/solutions/$id/visibility'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json',
      },
      body: json.encode({'visibility': visibility}),
    );

    if (response.statusCode == 200) {
      fetchSolutions(); // Başarılı değişiklikten sonra çözümleri güncelle
    } else {
      throw Exception('Görünürlük güncelleme hatası: ${response.statusCode}');
    }
  }

  void _toggleButtons(int index) {
    setState(() {
      _showButtonsList[index] = !_showButtonsList[index];

      if (_showButtonsList[index]) {
        if (_controllers[index].isDismissed) {
          _controllers[index].forward();
        }
      } else {
        if (_controllers[index].isCompleted) {
          _controllers[index].reverse();
        }
      }
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(243, 244, 246, 1),
      appBar: AppBar(
        title: const Text('Çözümler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Burada yeni çözüm eklemek için bir dialog açabilirsiniz
              addSolution();
              fetchSolutions();
            },
          ),
        ],
      ),
      body: solutions.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: solutions.length,
              itemBuilder: (context, index) {
                if (_showButtonsList.length < solutions.length) {
                  _showButtonsList.add(false);
                }

                final solution = solutions[index];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 10),
                        blurRadius: 15,
                        spreadRadius: -3,
                      ),
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.1),
                        offset: Offset(0, 4),
                        blurRadius: 6,
                        spreadRadius: -4,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          minHeight: 80, // Minimum yükseklik
                        ),
                        child: _showButtonsList[index]
                            ? SlideTransition(
                                position: _animations[index],
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        changeVisibilitySolution(solution['id'],
                                            solution['is_visibility']);
                                      },
                                      icon: Icon(
                                        solution['is_visibility'] == 1
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: solution['is_visibility'] == 1
                                            ? Colors.cyan
                                            : Colors.blueGrey,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        final result = await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SolutionsEditPage(solution)),
                                        );

                                        if (result == true) {
                                          fetchSolutions(); // Geri döndüğünde çözümleri çek
                                        }
                                      },
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Silme Onayı"),
                                              content: const Text(
                                                  "Bu çözümü silmek istediğinize emin misiniz?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Hayır"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    deleteSolution(
                                                        solution['id']);
                                                    Navigator.of(context)
                                                        .pop(); // Popup'ı kapat
                                                  },
                                                  child: const Text('Evet'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back_ios),
                                      onPressed: () => _toggleButtons(index),
                                    ),
                                  ],
                                ),
                              )
                            : Card(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                                child: ListTile(
                                  title: Text(solution['project_name'] ?? ''),
                                  subtitle: Text(
                                      solution['project_description'] ?? ''),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios),
                                    onPressed: () => _toggleButtons(index),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class SolutionsEditPage extends StatefulWidget {
  final Map<String, dynamic> solution;
  const SolutionsEditPage(this.solution, {super.key});

  @override
  State<SolutionsEditPage> createState() => _SolutionsEditPageState();
}

class _SolutionsEditPageState extends State<SolutionsEditPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.solution['project_name']);
    _descriptionController =
        TextEditingController(text: widget.solution['project_description']);
    _linkController =
        TextEditingController(text: widget.solution['project_link']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> updateSolution(
      int id, String name, String description, String link) async {
    final updatedSolution = {
      'project_name': name,
      'project_description': description,
      'project_link': link,
    };

    final response = await http.put(
      Uri.parse('http://localhost:3000/mobile/solutions/$id'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedSolution),
    );

    if (response.statusCode == 200) {
    } else {
      throw Exception('Güncelleme işlemi başarısız oldu');
    }
  }

  void _saveSolution() {
    if (_formKey.currentState!.validate()) {
      String updatedName = _nameController.text;
      String updatedDescription = _descriptionController.text;
      String updatedLink = _linkController.text;

      updateSolution(
          widget.solution['id'], updatedName, updatedDescription, updatedLink);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Çözüm güncellendi: $updatedName')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Çözüm Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSolution,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Çözüm Adı'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Çözüm adı boş olamaz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Açıklama'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Açıklama boş olamaz';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _linkController,
                decoration: const InputDecoration(labelText: 'Link'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Link boş olamaz';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Skill {
  final int id;
  final String skillName;
  final String skillType;
  final String? proficiencyLevel;
  int isVisible;

  Skill({
    required this.id,
    required this.skillName,
    required this.skillType,
    this.proficiencyLevel,
    this.isVisible = 1,
  });

  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      id: json['id'],
      skillName: json['skill_name'],
      skillType: json['skill_type'],
      proficiencyLevel: json['proficiency_level'] as String?,
      isVisible: json['is_visibility'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill_name': skillName,
      'skill_type': skillType,
      'proficiency_level': proficiencyLevel,
      'isVisible': isVisible,
    };
  }

  @override
  String toString() {
    return 'Skill(id: $id, skillName: $skillName, skillType: $skillType, proficiencyLevel: $proficiencyLevel), isVisible: $isVisible';
  }
}

class TechnicalLanguage {
  final int id;
  final int languages;

  TechnicalLanguage({required this.id, required this.languages});

  factory TechnicalLanguage.fromJson(Map<String, dynamic> json) {
    return TechnicalLanguage(
      id: json['id'],
      languages: json['languages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'languages': languages,
    };
  }

  @override
  String toString() {
    return 'TechnicalLanguage(id: $id, languages: $languages)';
  }
}





class SkillsPage extends StatefulWidget {
  const SkillsPage({super.key});

  @override
  State<SkillsPage> createState() => _SkillsPageState();
}

class _SkillsPageState extends State<SkillsPage> with TickerProviderStateMixin {
  Future<Map<String, dynamic>> fetchSkills() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/mobile/skills'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final skillsData = (data['skills'] as List)
          .map((skillJson) => Skill.fromJson(skillJson))
          .toList();

      final technicalLanguagesData = (data['technical_languages'] as List)
          .map((langJson) => TechnicalLanguage.fromJson(langJson))
          .toList();

      return {
        'skills': skillsData,
        'technical_languages': technicalLanguagesData,
      };
    } else {
      throw Exception('Failed to load skills');
    }
  }

  Future<void> changeVisibilitySkill(int id, int isVisibility) async {
    int visibility = isVisibility == 1 ? 0 : 1;
    debugPrint(isVisibility == 1 ? "Kapatıldı" : "Aktifleştirildi");

    final response = await http.put(
      Uri.parse(
          'http://localhost:3000/mobile/skills/$id/visibility'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json',
      },
      body: json.encode({'visibility': visibility}),
    );

    if (response.statusCode == 200) {
      debugPrint('Proje görünürlüğü başarıyla güncellendi.');
      setState(() {
        futureSkills = fetchSkills();
      });
    } else {
      throw Exception('Görünürlük güncelleme hatası: ${response.statusCode}');
    }
  }

  Future<void> updateSkill(Skill updatedSkill) async {
    final response = await http.put(
      Uri.parse('http://localhost:3000/mobile/skills/${updatedSkill.id}'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': updatedSkill.skillName,
        'visibility': updatedSkill.isVisible,
        'skillType': updatedSkill.skillType,
      }),
    );

    if (response.statusCode == 200) {
      debugPrint('Beceri başarıyla güncellendi.');
      setState(() {
        futureSkills = fetchSkills(); // Güncellenmiş becerileri al
      });
    } else {
      throw Exception('Güncelleme hatası: ${response.statusCode}');
    }
  }

  Future<void> deleteSkill(int id) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/mobile/skills/$id'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );
    if (response.statusCode == 200) {
      setState(() {
        futureSkills = fetchSkills(); // Yenile
      });
    } else {
      throw Exception('Silme işlemi başarısız oldu');
    }
  }



  late Future<Map<String, dynamic>> futureSkills;
  late TabController _tabController;
  late Map<String, int> programmingLanguages;
  late String addSkillType;

  Future<Map<String, int>> fetchProgrammingLanguages() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/mobile/programminglanguages'),
      headers: {'Authorization': 'Cumali Yelbiz'},
    );

    if (response.statusCode == 200) {
      List<dynamic> languages = json.decode(response.body);
      // Dillerin adını ve ID'sini eşleştir
      Map<String, int> programmingLanguage = {
        for (var lang in languages) lang['name']: lang['id'],
      };

      // Durumu güncellemek için setState'i burada kullanabilirsiniz
      setState(() {
        programmingLanguages = programmingLanguage;
      });

      return programmingLanguages; // Burada döndürme işlemi yapılır
    } else {
      throw Exception('Veri alınamadı');
    }
  }


  @override
  void initState() {
    super.initState();
    programmingLanguages = {}; // veya veri çekme işlemi burada yapılabilir
    fetchProgrammingLanguages().then((data) {
      setState(() {
        programmingLanguages = data; // veriyi atayın
      });
    });
    futureSkills = fetchSkills();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> addSkill(String skillType) async {
    final newSkill = {
      'skill_name': 'Yeni Beceri',
      'skill_type': skillType,
      'proficiency_level': "Yeni Yeterlilik",
    };

    final response = await http.post(
      Uri.parse('http://localhost:3000/mobile/skills'),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json'
      },
      body: json.encode(newSkill),
    );

    if (response.statusCode == 200) {
      setState(() {
        futureSkills = fetchSkills(); // Yenile
      });
    } else {
      throw Exception('Ekleme işlemi başarısız oldu');
    }
  }

  void addSkills() {
    addSkillType = (_tabController.index == 0) ? 'technical' : 'language';
    addSkill(addSkillType);
    debugPrint(addSkillType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Beceriler"),
        actions: [
          IconButton(
            onPressed: addSkills,
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Teknik Beceriler"),
            Tab(text: "Konuşma Dilleri"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: futureSkills,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final skills = snapshot.data!['skills'] as List<Skill>;
                final technicalLanguages = snapshot.data!['technical_languages'] as List<TechnicalLanguage>;

                final technicalSkills = skills.where((skill) => skill.skillType == 'technical').toList();

                return ListView.builder(
                  itemCount: technicalSkills.length,
                  itemBuilder: (context, index) {
                    return TechnicalSkillCard(
                      skill: technicalSkills[index],
                      index: index,
                      technicalLanguages: technicalLanguages,
                      onVisibilityChange: (id, visibility) {
                        changeVisibilitySkill(id, visibility);
                      },
                      onEdit: (updatedSkill) {
                        // Güncelleme işlemi
                        updateSkill(updatedSkill);
                      },
                      onDelete: (id) {
                        deleteSkill(id);
                      },
                      getItems: (id) {
                        setState(() {
                          futureSkills = fetchSkills();
                        });
                      },
                      programmingLanguages: programmingLanguages,
                    );
                  },
                );
              }
            },
          ),
          FutureBuilder<Map<String, dynamic>>(
            future: futureSkills,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final skills = snapshot.data!['skills'] as List<Skill>;

                final languageSkills = skills.where((skill) => skill.skillType == 'language').toList();

                return ListView.builder(
                  itemCount: languageSkills.length,
                  itemBuilder: (context, index) {
                    return LanguageSkillCard(
                      skill: languageSkills[index],
                      index: index,
                      onVisibilityChange: (id, visibility) {
                        changeVisibilitySkill(id, visibility);
                      },
                      onDelete: (id) {
                        deleteSkill(id);
                      },
                      getItems: (id) {
                        setState(() {
                          futureSkills = fetchSkills();
                        });
                      },
                      programmingLanguages: programmingLanguages,
                    );
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class TechnicalSkillCard extends StatefulWidget {
  final Skill skill;
  final int index;
  final List<TechnicalLanguage> technicalLanguages;
  final Function(int, int) onVisibilityChange;
  final Function(Skill) onEdit;
  final Function(int) onDelete;
  final Function(int) getItems;
  final Map<String, int> programmingLanguages;

  const TechnicalSkillCard({
    required this.skill,
    required this.index,
    required this.technicalLanguages,
    required this.onVisibilityChange,
    required this.onEdit,
    required this.onDelete,
    required this.getItems,
    required this.programmingLanguages,
    super.key,
  });

  @override
  TechnicalSkillCardState createState() => TechnicalSkillCardState();
}

class TechnicalSkillCardState extends State<TechnicalSkillCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _areButtonsVisible = false;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleButtons() {
    setState(() {
      if (_areButtonsVisible) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      _areButtonsVisible = !_areButtonsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(widget.programmingLanguages.isEmpty)
    {
      return const CircularProgressIndicator();
    }

    List<int> relatedLanguageIds = widget.technicalLanguages
        .where((lang) => lang.id == widget.skill.id)
        .map((lang) => lang.languages)
        .toList();

    List<String> relatedLanguageNames = relatedLanguageIds
        .map((id) => widget.programmingLanguages.keys.firstWhere((key) => widget.programmingLanguages[key] == id, orElse: () => ''))
        .toList();

    return GestureDetector(
      onTap: _toggleButtons,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.skill.skillName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.skill.skillType != 'technical')
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Yeterlilik: ${widget.skill.proficiencyLevel}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        if (relatedLanguageNames.isNotEmpty)
                          Text(
                            'Teknik Diller: ${relatedLanguageNames.join(", ")}',
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onVisibilityChange(widget.skill.id, widget.skill.isVisible);
                    },
                    icon: Icon(
                      widget.skill.isVisible == 1 ? Icons.visibility : Icons.visibility_off,
                      color: widget.skill.isVisible == 1 ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizeTransition(
                sizeFactor: _animation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      child: const Text("Düzenle"),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SkillsEditPage(widget.skill, widget.technicalLanguages,widget.programmingLanguages)),
                        );

                        if (result == true) {
                          widget.getItems(1);
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.onDelete(widget.skill.id);
                      },
                      child: const Text("Sil"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LanguageSkillCard extends StatefulWidget {
  final Skill skill;
  final int index;
  final Function(int, int) onVisibilityChange;
  final Function(int) onDelete;
  final Function(int) getItems;
  final Map<String, int> programmingLanguages;

  const LanguageSkillCard({
    required this.skill,
    required this.index,
    required this.onVisibilityChange,
    required this.onDelete,
    required this.getItems,
    required this.programmingLanguages,
    super.key,
  });

  @override
  LanguageSkillCardState createState() => LanguageSkillCardState();
}

class LanguageSkillCardState extends State<LanguageSkillCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _areButtonsVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleButtons() {
    setState(() {
      if (_areButtonsVisible) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      _areButtonsVisible = !_areButtonsVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleButtons,
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.skill.skillName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        if (widget.skill.proficiencyLevel != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Yeterlilik: ${widget.skill.proficiencyLevel}',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      widget.onVisibilityChange(widget.skill.id, widget.skill.isVisible);
                    },
                    icon: Icon(
                      widget.skill.isVisible == 1 ? Icons.visibility : Icons.visibility_off,
                      color: widget.skill.isVisible == 1 ? Colors.green : Colors.grey,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizeTransition(
                sizeFactor: _animation,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SkillsEditPage(widget.skill,null,widget.programmingLanguages)),
                        );

                        if (result == true) {
                          widget.getItems(1);
                        }
                      },
                      child: const Text("Düzenle"),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        widget.onDelete(widget.skill.id);
                      },
                      child: const Text("Sil"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SkillsEditPage extends StatefulWidget {
  final Skill skill;
  final List<TechnicalLanguage>? technicalLanguages;
  final Map<String, int> programmingLanguages;

  const SkillsEditPage(this.skill, this.technicalLanguages, this.programmingLanguages, {super.key});

  @override
  State<SkillsEditPage> createState() => _SkillsEditPageState();
}

class _SkillsEditPageState extends State<SkillsEditPage> {
  final _formKey = GlobalKey<FormState>();
  late String _skillName;
  late String _skillDescription;
  List<int> _selectedLanguages = [];
  Map<String, int> _allLanguages = {};
  late List<MapEntry<String, int>> _availableLanguages;
  List<bool> selections = [];

  @override
  void initState() {
    super.initState();
    _allLanguages = widget.programmingLanguages;
    _skillName = widget.skill.skillName;
    if (widget.skill.proficiencyLevel != null) {
      _skillDescription = widget.skill.proficiencyLevel!;
    }
    _selectedLanguages = widget.technicalLanguages
        ?.where((language) => language.id == widget.skill.id)
        .map((e) => e.languages) // Veya istediğin alan
        .toList() ?? [];
    _availableLanguages = _allLanguages.entries
        .toList();
    selections = List.generate(
      _availableLanguages.length,
          (index) => _selectedLanguages.contains(_availableLanguages[index].value),
    );
  }

  void _saveSkill() {
    updateSkill();
    Navigator.pop(context, true);
  }

  Future<void> updateSkill() async {
    final response = await http.put(
      Uri.parse("http://localhost:3000/mobile/skills/${widget.skill.id}"),
      headers: {
        'Authorization': 'Cumali Yelbiz',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'skill_name': _skillName, // Örnek, skill_name'i widget'tan alıyoruz
        'skill_type': widget.skill.skillType, // Örnek, skill_type'i widget'tan alıyoruz
        'proficiency_level': _skillDescription, // Örnek, proficiency_level'i widget'tan alıyoruz
        'selectedLanguages': _selectedLanguages, // Seçilen diller
      }),
    );

    if (response.statusCode == 200) {
      // Başarılı bir şekilde gönderildi
      debugPrint('Seçilen diller başarıyla gönderildi.');
    } else {
      throw Exception('Diller gönderilemedi: ${response.body}');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beceri Düzenle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSkill,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  initialValue: _skillName,
                  decoration: const InputDecoration(labelText: 'Beceri Adı'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Beceri adı boş olamaz!';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _skillName = value;
                  },
                ),
                const SizedBox(height: 16),
                if (widget.skill.skillType == 'language')
                TextFormField(
                  initialValue: _skillDescription,
                  decoration: const InputDecoration(labelText: 'Açıklama'),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Açıklama boş olamaz!';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    _skillDescription = value;
                  },
                ),
                const SizedBox(height: 16),
                if (widget.skill.skillType == 'technical')
                const Text('Teknik Diller'),
                const SizedBox(height: 10),
                if (widget.skill.skillType == 'technical')
                  Container(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 1.4,
                    ),
                    itemCount: _availableLanguages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            int langId = _availableLanguages[index].value;
                            if (selections[index]) {
                              selections[index] = false; // Seçimi kaldır
                              _selectedLanguages.remove(langId); // Listeden çıkar
                            } else {
                              selections[index] = true; // Seç
                              _selectedLanguages.add(langId); // Listeye ekle
                            }
                            debugPrint(_selectedLanguages.toString());
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: selections[index] ? Colors.blueAccent : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _availableLanguages[index].key,
                              style: TextStyle(
                                color: selections[index] ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
