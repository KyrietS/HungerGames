class XmlWriter
{
  XmlWriter(ArrayList<Vertice> verts)
  {
    vertices = verts;
  }

  boolean createEntity(String name)
  {
    XML[] entities = data.getChildren();
    for (int i = 0; i < entities.length; i++ )
    {
      if (entities[i].getString("name"," ").equals(name))
      {
        println("XmlWriter: cannot create entity, entity exists with the same name!");
        return false;
      }
    }
    data.addChild("entity");
    data.getChild(data.getChildCount() - 1).setString("name", name);
    return true;
  }
  void createVertex(Vertice vert, String _entity)
  {
    XML entities[] = data.getChildren("entity");
    for (int i = 0; i < entities.length; i++)
    {
        XML entity = entities[i];
      if (entity.getString("name"," ").equals(_entity))
      {
        entity.addChild("vertex");
        entity.getChild(entity.getChildCount()-1).setFloat("x", mesh.getTruePos(vert.getPos()).x);
        entity.getChild(entity.getChildCount()-1).setFloat("y", mesh.getTruePos(vert.getPos()).y);
      }
    }
  }

  void createAnchorPoint(String _entity, float x, float y)
  {
    XML entities[] = data.getChildren("entity");
    for (int i = 0; i < entities.length; i++)
    {
      if (entities[i].getString("name"," ").equals(_entity))
      {
        XML entity = entities[i];
        entity.addChild("anchor-point");
        entity.getChild(entity.getChildCount()-1).setFloat("x", x);
        entity.getChild(entity.getChildCount()-1).setFloat("y", y);
      }
    }
  }

  void createColor(String _entity, String hex)
  {
    XML entities[] = data.getChildren("entity");
    for (int i = 0; i < entities.length; i++)
    {
      if (entities[i].getString("name"," ").equals(_entity))
      {
        XML entity = entities[i];
        entity.addChild("color");
        entity.getChild(entity.getChildCount()-1).setString("value", hex);
      }
    }
  }

  void saveObject(String name, String c, float x, float y)
  {
    if (saved == false)
    {
      if(createEntity(name)== true)
      {
        println("carry out");
        for (int i = 0; i < vertices.size(); i ++)
        {
          createVertex(vertices.get(i), name);
        }
        createAnchorPoint(name, x, y);
        createColor(name, c);
        saveXML(data, "Entities.xml");
        saved = true;
      }
    }
  }
  XML data = loadXML("Entities.xml");
  Boolean saved = false;
  ArrayList<Vertice> vertices;
  String entityName;
}