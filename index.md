---
layout: default
title: Home
slug: home
paginate:
  permalink: /page/:num/
lang: fr
---

<div class="post-list">
  {% for post in paginator.posts %}
    {% include post.html %}
  {% endfor %}

  {% include pagination.html %}
</div>

<script type="application/ld+json">
{ "@context": "http://schema.org", 
 "@type": "Blog",
 "name": "Le Crochet d'Argent",
 "description": "Créations et réalisations au tricot et crochet", 
 "keywords": "blog de tricot, loisirs créatifs, modèles, crochet, tricot, blog, crocheter, tricoter", 
 "url": "https://www.lecrochetdargent.fr",
 "sameAs": [
     "https://twitter.com/crochetdargent",
     "https://facebook.com/crochetdargent",
     "https://framapiaf.org/@crochetdargent"
 ],
 "publisher": {
    "@type": "Organization",
    "name": "Le Crochet d'Argent"
  }
 }
</script>

{% assign items = "" %}
{% for post in site.posts %}
  {% capture list_item %}
      {% 
          include blog-list-item.html 
          index=forloop.index
          url=post.url
          title=post.title
          date=post.date
      %}
  {% endcapture %}
  {% assign items = items | append: list_item | append: "|||" %}
{% endfor %}
  
{% assign items = items | split: "|||" | join: ',' %}
<script type="application/ld+json">
{
  "@context": "http://schema.org",
  "@type": "ItemList",
  "itemListElement": [
  {{ items }}
  ]
}
</script>
