import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../model/simple_entity.dart';
import 'entity_add.dart';

class EntityManagementScreen extends StatefulWidget {
  final String title;
  final String entityName;

  const EntityManagementScreen({
    required this.title,
    required this.entityName,
    super.key,
  });

  @override
  State<EntityManagementScreen> createState() => _EntityManagementScreenState();
}

class _EntityManagementScreenState extends State<EntityManagementScreen> {
  List<SimpleEntity> entities = [
    SimpleEntity(id: 'H001', name: 'Ameli'),
    SimpleEntity(id: 'H002', name: 'Jean-Marc'),
  ];

  @override
  void initState() {
    super.initState();
  }

  void _openAddModal() async {
    final newEntity = await showDialog<SimpleEntity>(
      context: context,
      builder: (context) => AddSimpleEntityModal(entityName: widget.entityName),
    );

    if (newEntity != null) {
      setState(() {
        entities.add(newEntity);
      });
    }
  }

  void _deleteEntity(int index) {
    setState(() {
      entities.removeAt(index);
    });
  }
  bool isMobile = defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;
  @override
  Widget build(BuildContext context) {
    if (widget.entityName == 'Matériel') {
      entities = [
        SimpleEntity(id: 'M001', name: 'Escalier'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
        SimpleEntity(id: 'M002', name: 'Perceuse'),
      ];
    } else if (widget.entityName == 'Camion') {
      entities = [
        SimpleEntity(id: 'C001', name: 'Renault T450'),
        SimpleEntity(id: 'C002', name: 'Ford F150'),
      ];
    }
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(
                    Icons.add_circle,
                    color: Colors.blue.shade700,
                    size: 40,
                  ),
                  onPressed: _openAddModal,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: isMobile  ? MediaQuery.of(context).size.height *0.7 : MediaQuery.of(context).size.height *0.8 ,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: entities.length,
                itemBuilder: (context, index) {
                  final entity = entities[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(
                        entity.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("ID: ${entity.id}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              size: 20,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              // TODO: Ouvrir un modal de modification
                            },
                          ),
                          // Icône de suppression
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              size: 20,
                              color: Colors.red,
                            ),
                            onPressed: () => _deleteEntity(index),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
