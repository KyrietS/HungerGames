XML loadFile(String path)
{
  XML file = loadXML(path);
  if ( file == null )             // Checks if file was loaded correctly.
  {
    println("Problem with reading from file.");
  }
  return file;
}

Boolean validateAttributes(XML entity, String[] attributes)
{
  if (entity == null)
    return false;

  for (int i = 0; i < attributes.length; i++)
  {
    if (!entity.hasAttribute(attributes[i]))
    {
      return false;
    }
  }
  return true;
}

Boolean validateAttributes(XML entity, String attribute)
{
  if (entity == null)
    return false;
  if (!entity.hasAttribute(attribute))
  {
    return false;
  }
  return true;
}