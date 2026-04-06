import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poke/models/poke_type.dart';
import 'package:poke/models/pokemon.dart';
import 'package:poke/providers/pokemon_provider.dart';
import 'package:poke/providers/type_prov.dart';
import 'package:poke/utilities/type_colors.dart';
import 'package:poke/widgets/pokemongriditem.dart';

class TypesTab extends ConsumerWidget {
  const TypesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedTypeProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, anim) =>
          FadeTransition(opacity: anim, child: child),
      child: selected == null
          ? const _TypeGrid(key: ValueKey('grid'))
          : _TypeDetail(typeName: selected, key: ValueKey(selected)),
    );
  }
}

// ── Type grid ─────────────────────────────────────────────────────────────────

class _TypeGrid extends ConsumerWidget {
  const _TypeGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text(
            'Types',
            style: TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: Colors.white.withOpacity(0.08)),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final typeName = kAllTypeNames[index];
                final color = TypeColors.of(typeName);
                final textColor = TypeColors.textOn(typeName);

                return GestureDetector(
                  onTap: () =>
                      ref.read(selectedTypeProvider.notifier).state = typeName,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Stack(
                      children: [
                        // Decorative Poké Ball watermark
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: Opacity(
                            opacity: 0.15,
                            child: _PokeballShape(color: textColor, size: 56),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              capitalize(typeName),
                              style: TextStyle(
                                color: textColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: kAllTypeNames.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _TypeDetail extends ConsumerWidget {
  final String typeName;
  const _TypeDetail({required this.typeName, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typeAsync = ref.watch(pokemonTypeProvider(typeName));
    final color = TypeColors.of(typeName);
    final textColor = TypeColors.textOn(typeName);

    return typeAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      error: (e, _) => Center(
        child: Text('Error: $e', style: const TextStyle(color: Colors.white70)),
      ),
      data: (type) {
        if (type == null) {
          return const Center(
            child: Text('No data', style: TextStyle(color: Colors.white70)),
          );
        }

        return CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              pinned: true,
              backgroundColor: color,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
                onPressed: () =>
                    ref.read(selectedTypeProvider.notifier).state = null,
              ),
              title: Text(
                capitalize(typeName),
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              expandedHeight: 140,
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: color),
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Opacity(
                        opacity: 0.12,
                        child: _PokeballShape(color: textColor, size: 160),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      bottom: 16,
                      child: Text(
                        '${type.pokemon.length} Pokémon',
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Damage relations card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _DamageRelationsCard(
                    relations: type.damageRelations, typeColor: color),
              ),
            ),

            // Pokémon section label
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                child: Row(
                  children: [
                    Container(
                      width: 4,
                      height: 18,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${capitalize(typeName)} Pokémon',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Pokémon list
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final entry = type.pokemon[index].pokemon;
                    return PokemonGridItem(
                      index: index,
                      pokemon: PokemonListResult(
                        name: entry.name,
                        url: entry.url,
                      ),
                      searchController: TextEditingController(),
                      onTap: () {},
                    );
                  },
                  childCount: type.pokemon.length,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ── Damage relations card ─────────────────────────────────────────────────────

class _DamageRelationsCard extends StatelessWidget {
  final DamageRelations relations;
  final Color typeColor;

  const _DamageRelationsCard({
    required this.relations,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF252545),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Damage relations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),

          // Attacking
          _SectionLabel(label: 'When attacking', color: typeColor),
          const SizedBox(height: 8),
          _RelationRow(
            label: '2×',
            labelColor: const Color(0xFF4ADE80),
            types: relations.doubleDamageTo,
          ),
          const SizedBox(height: 6),
          _RelationRow(
            label: '½×',
            labelColor: const Color(0xFFFBBF24),
            types: relations.halfDamageTo,
          ),
          const SizedBox(height: 6),
          _RelationRow(
            label: '0×',
            labelColor: const Color(0xFFF87171),
            types: relations.noDamageTo,
          ),

          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 10),

          // Defending
          _SectionLabel(label: 'When defending', color: typeColor),
          const SizedBox(height: 8),
          _RelationRow(
            label: '2×',
            labelColor: const Color(0xFFF87171),
            types: relations.doubleDamageFrom,
          ),
          const SizedBox(height: 6),
          _RelationRow(
            label: '½×',
            labelColor: const Color(0xFF4ADE80),
            types: relations.halfDamageFrom,
          ),
          const SizedBox(height: 6),
          _RelationRow(
            label: '0×',
            labelColor: const Color(0xFF60A5FA),
            types: relations.noDamageFrom,
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _RelationRow extends StatelessWidget {
  final String label;
  final Color labelColor;
  final List<TypeRef> types;

  const _RelationRow({
    required this.label,
    required this.labelColor,
    required this.types,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: types.isEmpty
              ? Text(
                  '—',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.3),
                    fontSize: 12,
                  ),
                )
              : Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children:
                      types.map((t) => _TypeChip(typeName: t.name)).toList(),
                ),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String typeName;
  const _TypeChip({required this.typeName});

  @override
  Widget build(BuildContext context) {
    final color = TypeColors.of(typeName);
    final textColor = TypeColors.textOn(typeName);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        capitalize(typeName),
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Decorative Poké Ball shape ────────────────────────────────────────────────

class _PokeballShape extends StatelessWidget {
  final Color color;
  final double size;
  const _PokeballShape({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _PokeballPainter(color: color)),
    );
  }
}

class _PokeballPainter extends CustomPainter {
  final Color color;
  const _PokeballPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, paint);
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    final innerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05;
    canvas.drawCircle(center, radius * 0.22, innerPaint);
  }

  @override
  bool shouldRepaint(_PokeballPainter oldDelegate) =>
      oldDelegate.color != color;
}
